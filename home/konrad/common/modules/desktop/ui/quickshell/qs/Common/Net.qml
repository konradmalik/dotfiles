pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Config

// Quickshell's own Networking service speaks only to NetworkManager, and these
// machines run iwd, so the link state is read the way impala reads it: iwd over
// the system bus for the station and the ssid, iproute2 for addresses, and the
// station diagnostic for the rssi the icon needs.
Singleton {
    id: root

    property string kind: "none"
    property string iface: ""
    property string ssid: ""
    property string address: ""
    property real strength: 0

    property var links: []
    property string wifiDevice: ""
    property string wifiPath: ""
    property string wifiState: ""

    function addressOf(name) {
        const link = root.links.find(l => l.ifname === name);
        const info = link?.addr_info?.find(a => a.family === "inet");
        return info ? info.local + "/" + info.prefixlen : "";
    }

    // Anything carrying an address that is neither loopback, the wifi device,
    // nor a tunnel counts as a wire. Tailscale in particular is always up and
    // would otherwise read as the active link.
    function wired() {
        return root.links.find(l => l.ifname !== "lo" && l.ifname !== root.wifiDevice && l.operstate === "UP" && !l.link_info && root.addressOf(l.ifname) !== "") ?? null;
    }

    function resolve() {
        const wire = root.wired();

        if (wire) {
            root.kind = "ethernet";
            root.iface = wire.ifname;
            root.ssid = "";
            root.address = root.addressOf(wire.ifname);
        } else if (root.wifiState === "connected") {
            root.kind = "wifi";
            root.iface = root.wifiDevice;
            root.address = root.addressOf(root.wifiDevice);
        } else {
            root.kind = "none";
            root.iface = "";
            root.ssid = "";
            root.address = "";
            root.strength = 0;
        }
    }

    function poll() {
        if (!linkProc.running)
            linkProc.running = true;
        if (!iwdProc.running)
            iwdProc.running = true;
    }

    property Process linkProc: Process {
        id: linkProc

        command: [Env.ip, "-j", "addr"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.links = Cmd.json(this.text, []);
                root.resolve();
            }
        }
    }

    property Process iwdProc: Process {
        id: iwdProc

        command: [Env.busctl, "--system", "--json=short", "call", "net.connman.iwd", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiDevice = "";
                root.wifiPath = "";
                root.wifiState = "";

                const objects = Cmd.json(this.text, {}).data?.[0] ?? {};
                let connected = "";

                for (const path in objects) {
                    const station = objects[path]["net.connman.iwd.Station"];
                    if (!station)
                        continue;
                    root.wifiPath = path;
                    root.wifiState = station.State?.data ?? "";
                    root.wifiDevice = objects[path]["net.connman.iwd.Device"]?.Name?.data ?? "";
                    connected = station.ConnectedNetwork?.data ?? "";
                }

                root.ssid = objects[connected]?.["net.connman.iwd.Network"]?.Name?.data ?? "";

                root.resolve();

                if (root.wifiState === "connected" && root.wifiPath !== "" && !diagProc.running) {
                    diagProc.command = [Env.busctl, "--system", "--json=short", "call", "net.connman.iwd", root.wifiPath, "net.connman.iwd.StationDiagnostic", "GetDiagnostics"];
                    diagProc.running = true;
                }
            }
        }
    }

    property Process diagProc: Process {
        id: diagProc

        stdout: StdioCollector {
            onStreamFinished: {
                const rssi = Cmd.json(this.text, {}).data?.[0]?.RSSI?.data;
                // -80 dBm is the bottom of usable and -40 is right next to the
                // access point; the five icons are spread over that.
                root.strength = rssi === undefined ? 0 : Math.max(0, Math.min(1, (rssi + 80) / 40));
            }
        }
    }

    property Timer timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.poll()
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Config

// Quickshell's own Networking service speaks only to NetworkManager -- its
// backend enum has no second entry -- and these machines run iwd, so the link
// state is read the way impala reads it: iwd over the system bus for the
// station and the ssid, iproute2 for addresses, and the station diagnostic for
// the rssi the icon needs.
//
// Nothing here parses anything it did not ask for as json. `ip monitor` is run
// for its noise alone: a line off it only has to mean "something moved, ask
// again", and what it asks is the same structured read that ran at startup.
// That covers iwd too, because every transition the bar shows -- associating,
// dhcp handing an address over, the link going away -- moves netlink as well.
Singleton {
    id: root

    // The three raw answers. Everything below is derived from them, so a link
    // going away cannot leave a stale ssid or address behind it -- there is
    // nothing to clear, only something that stops being found.
    property var links: []
    property var objects: ({})

    // -80 dBm is the bottom of usable and -40 is right next to the access
    // point; the five icons are spread over that. Starting at the bottom means
    // a diagnostic that never answers reads as the weakest icon rather than as
    // no link at all.
    property real rssi: -80

    function addressOf(name) {
        const link = root.links.find(l => l.ifname === name);
        const info = link?.addr_info?.find(a => a.family === "inet");
        return info ? info.local + "/" + info.prefixlen : "";
    }

    // iwd hangs the Station and the Device off one object path, and the ssid
    // off a separate Network object that the station points at.
    readonly property string stationPath: Object.keys(root.objects).find(p => root.objects[p]["net.connman.iwd.Station"]) ?? ""
    readonly property var station: root.objects[root.stationPath]?.["net.connman.iwd.Station"] ?? null
    readonly property string wifiDevice: root.objects[root.stationPath]?.["net.connman.iwd.Device"]?.Name?.data ?? ""

    // A wire is anything that is not loopback or the wifi device, is carrying
    // an address, and says UP rather than UNKNOWN. That last part is what keeps
    // tunnels out: tailscale is always up and would otherwise read as the
    // active link, but a tun device has no carrier to report, so it sits at
    // UNKNOWN and never qualifies.
    readonly property var wire: root.links.find(l => l.ifname !== "lo" && l.ifname !== root.wifiDevice && l.operstate === "UP" && root.addressOf(l.ifname) !== "") ?? null

    readonly property string kind: root.wire ? "ethernet" : root.station?.State?.data === "connected" ? "wifi" : "none"
    readonly property string iface: root.kind === "ethernet" ? root.wire.ifname : root.kind === "wifi" ? root.wifiDevice : ""
    readonly property string ssid: root.kind === "wifi" ? root.objects[root.station?.ConnectedNetwork?.data]?.["net.connman.iwd.Network"]?.Name?.data ?? "" : ""
    readonly property string address: root.addressOf(root.iface)
    readonly property real strength: root.kind === "wifi" ? Math.max(0, Math.min(1, (root.rssi + 80) / 40)) : 0

    function read() {
        linkProc.running = true;
        iwdProc.running = true;
    }

    property Process linkProc: Process {
        id: linkProc

        command: [Env.ip, "-j", "addr"]
        stdout: StdioCollector {
            onStreamFinished: root.links = Cmd.json(this.text, [])
        }
    }

    property Process iwdProc: Process {
        id: iwdProc

        command: [Env.busctl, "--system", "--json=short", "call", "net.connman.iwd", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects"]
        stdout: StdioCollector {
            onStreamFinished: root.objects = Cmd.json(this.text, {}).data?.[0] ?? {}
        }
    }

    property Process diagProc: Process {
        id: diagProc

        command: [Env.busctl, "--system", "--json=short", "call", "net.connman.iwd", root.stationPath, "net.connman.iwd.StationDiagnostic", "GetDiagnostics"]
        stdout: StdioCollector {
            onStreamFinished: root.rssi = Cmd.json(this.text, {}).data?.[0]?.RSSI?.data ?? -80
        }
    }

    // Netlink says when an address or a link changes, which covers the wire
    // coming and going and the address dhcp hands over.
    property Process linkMonitor: Process {
        id: linkMonitor

        command: [Env.ip, "-oneline", "monitor", "address", "link"]
        stdout: SplitParser {
            onRead: settle.restart()
        }
    }

    // One change arrives as a burst -- a link comes up and is then given an
    // address, dhcp renews and rewrites one -- so the re-read waits for the
    // burst to end instead of running once per line.
    property Timer settle: Timer {
        id: settle

        interval: 200
        onTriggered: root.read()
    }

    // The monitor is what makes this immediate; the tick is what makes it right
    // anyway. It starts the monitor, brings it back if it died, and re-reads
    // regardless -- so the one thing netlink can stay quiet about, iwd moving
    // between states without the interface under it moving, is stale for a tick
    // rather than until the next change that does move it.
    property Timer tick: Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            linkMonitor.running = true;
            root.read();
        }
    }

    // The rssi drifts with the room rather than changing on an event, and iwd
    // has no signal carrying it, so it is the one thing polled -- and only
    // while there is a wifi link whose strength is on screen to be wrong. Five
    // icons spread over 40 dBm do not need it any oftener than the tick.
    property Timer rssiTick: Timer {
        interval: 15000
        running: root.kind === "wifi"
        repeat: true
        triggeredOnStart: true
        onTriggered: diagProc.running = true
    }
}

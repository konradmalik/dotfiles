pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs.Common
import qs.Config

// Only wifi and ethernet devices reach Networking.devices, so tunnels need no
// excluding here: tailscale is simply not in the list.
Singleton {
    id: root

    readonly property var devices: Networking.devices.values

    readonly property var wire: root.devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifi: root.devices.find(d => d.type === DeviceType.Wifi && d.connected) ?? null
    readonly property var network: root.kind === "wifi" ? root.wifi?.networks?.values?.find(n => n.connected) ?? null : null

    readonly property string kind: root.wire ? "ethernet" : root.wifi ? "wifi" : "none"
    readonly property string iface: (root.wire ?? root.wifi)?.name ?? ""
    readonly property string ssid: root.network?.name ?? ""

    // a fraction, not a percentage
    readonly property real strength: root.network?.signalStrength ?? 0

    // NetworkDevice.address is the mac and the service exposes no ip config, so
    // the address is the one thing still read out of band. A device reaches
    // "connected" only once NetworkManager has configured ip; the network
    // changes on a roam, which renews the lease without iface moving.
    property var links: []
    readonly property string address: {
        const link = root.links.find(l => l.ifname === root.iface);
        const info = link?.addr_info?.find(a => a.family === "inet");
        return info ? info.local + "/" + info.prefixlen : "";
    }

    onIfaceChanged: settle.restart()
    onNetworkChanged: settle.restart()

    property Timer settle: Timer {
        id: settle

        interval: 150
        running: true
        onTriggered: addrProc.running = true
    }

    property Process addrProc: Process {
        id: addrProc

        command: [Env.ip, "-j", "addr"]
        stdout: StdioCollector {
            onStreamFinished: root.links = Cmd.json(this.text, [])
        }
    }
}

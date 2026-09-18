pragma Singleton
import Quickshell

// Fallback only. The Nix module overwrites this file with the values for the
// host being built; it is checked in so that qmlls can resolve qs.Config, and
// so that `quickshell -p src` runs straight from the working tree.
Singleton {
    readonly property var colors: ({
            base00: "#1f1f28",
            base01: "#16161d",
            base02: "#223249",
            base03: "#54546d",
            base04: "#727169",
            base05: "#dcd7ba",
            base06: "#c8c093",
            base07: "#717c7c",
            base08: "#c34043",
            base09: "#ffa066",
            base0A: "#c0a36e",
            base0B: "#76946a",
            base0C: "#6a9589",
            base0D: "#7e9cd8",
            base0E: "#957fb8",
            base0F: "#d27e99"
        })

    readonly property string fontFamily: "Iorkeley Nerd Font"
    readonly property int fontSize: 10
    readonly property string popupFontFamily: "Ubuntu Sans"
    readonly property int popupFontSize: 11

    readonly property bool hasBattery: false
    readonly property bool hasBacklight: false
    readonly property bool hasTailscale: true
    readonly property bool hasPowerProfiles: false

    readonly property string distro: "NixOS"

    readonly property list<string> terminalArgv: ["alacritty", "-e", "/bin/sh", "-c"]
    readonly property list<string> tailscaleToggle: ["true"]
    readonly property list<string> tailscaleCopyIp: ["true"]

    readonly property string systemMonitor: "btop"
    readonly property string mixer: "wiremix"
    readonly property string wifiTui: "impala"
    readonly property string bluetoothTui: "bluetui"

    readonly property string sh: "sh"
    readonly property string uptime: "uptime"
    readonly property string systemctl: "systemctl"
    readonly property string loginctl: "loginctl"
    readonly property string hyprctl: "hyprctl"
    readonly property string ip: "ip"
    readonly property string busctl: "busctl"
    readonly property string brightnessctl: "brightnessctl"
    readonly property string tailscale: "tailscale"
}

import QtQuick
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property list<string> wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    text: {
        if (Net.kind === "ethernet")
            return "󰈀";
        if (Net.kind === "wifi")
            return wifiIcons[Math.min(wifiIcons.length - 1, Math.round(Net.strength * (wifiIcons.length - 1)))];
        return "󰤭";
    }
    color: Net.kind === "none" ? Theme.muted : Theme.text
    tooltip: {
        if (Net.kind === "none")
            return "Disconnected";
        const lines = [Net.iface];
        if (Net.ssid !== "")
            lines.push(Net.ssid);
        if (Net.address !== "")
            lines.push(Net.address);
        return lines.join("\n");
    }

    onLeftClicked: Cmd.term(Env.wifiTui)
}

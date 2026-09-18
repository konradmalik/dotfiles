import QtQuick
import Quickshell.Services.UPower
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property real level: battery?.percentage ?? 0
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property bool full: battery?.state === UPowerDeviceState.FullyCharged

    readonly property list<string> chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property list<string> dischargingIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    function bucket(icons) {
        return icons[Math.min(icons.length - 1, Math.floor(root.level * icons.length))];
    }

    function duration(seconds) {
        if (!seconds || seconds <= 0)
            return "";
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    active: Env.hasBattery && (battery?.isLaptopBattery ?? false)
    text: full ? "" : bucket(charging ? chargingIcons : dischargingIcons)
    color: !charging && level <= 0.15 ? Theme.urgent : !charging && level <= 0.30 ? Theme.warning : Theme.text
    tooltip: {
        if (!battery)
            return "";
        const watts = Math.round(Math.abs(battery.changeRate));
        const left = root.duration(charging ? battery.timeToFull : battery.timeToEmpty);
        const arrow = charging ? "↑" : "↓";
        return watts + "W" + arrow + " " + Math.round(level * 100) + "%" + (left ? " " + left : "");
    }
}

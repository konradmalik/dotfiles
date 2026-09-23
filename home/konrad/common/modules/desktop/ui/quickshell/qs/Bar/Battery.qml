pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
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

    readonly property var profileOrder: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

    readonly property var profileIcons: {
        const map = {};
        map[PowerProfile.PowerSaver] = "󰌪";
        map[PowerProfile.Balanced] = "";
        map[PowerProfile.Performance] = "󰓅";
        return map;
    }

    // Only what the daemon advertises in Profiles: a machine whose drivers
    // carry no performance profile is not offered one, because quickshell
    // refuses that write and the row would do nothing. tlp-pd advertises all
    // three whatever the hardware, so this only bites under plain
    // power-profiles-daemon.
    readonly property var availableProfiles: profileOrder.filter(p => p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

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
    text: full ? "" : bucket(charging ? chargingIcons : dischargingIcons)
    color: !charging && level <= 0.15 ? Theme.urgent : !charging && level <= 0.30 ? Theme.warning : Theme.text
    tooltip: {
        if (!battery)
            return "";
        const watts = Math.round(Math.abs(battery.changeRate));
        const left = root.duration(charging ? battery.timeToFull : battery.timeToEmpty);
        const arrow = charging ? "↑" : "↓";
        const lines = [watts + "W" + arrow + " " + Math.round(level * 100) + "%" + (left ? " " + left : "")];
        if (Env.hasPowerProfiles)
            lines.push("Profile: " + PowerProfile.toString(PowerProfiles.profile));
        return lines.join("\n");
    }

    // The charge is only worth clicking on where there is something to change
    // about it.
    onLeftClicked: {
        if (Env.hasPowerProfiles)
            root.popupOpen = !root.popupOpen;
    }

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Dropdown {
                width: Theme.popupWidth
                title: "Profile"
                current: PowerProfiles.profile
                options: root.availableProfiles.map(p => ({
                            value: p,
                            label: PowerProfile.toString(p),
                            icon: root.profileIcons[p]
                        }))

                // The popup holds nothing else, so there is no point making
                // someone open the list before they can pick from it.
                expanded: true

                onPicked: value => {
                    PowerProfiles.profile = value;
                    root.popupOpen = false;
                }
            }
        }
    }
}

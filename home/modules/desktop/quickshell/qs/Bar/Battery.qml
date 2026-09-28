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
    readonly property string percent: Math.round(level * 100) + "%"

    // Being on AC is not the same as charging: once full, or held by the
    // charge thresholds, the battery sits on AC in FullyCharged, PendingCharge
    // or even Discharging.
    readonly property string status: battery?.state === UPowerDeviceState.Charging ? "charging" : UPower.onBattery ? "discharging" : "plugged"

    readonly property list<string> chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property list<string> dischargingIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    readonly property var profileOrder: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

    readonly property var profileIcons: ({
            [PowerProfile.PowerSaver]: "󰌪",
            [PowerProfile.Balanced]: "",
            [PowerProfile.Performance]: "󰓅"
        })

    // Only what the daemon advertises in Profiles: a machine whose drivers
    // carry no performance profile is not offered one, because quickshell
    // refuses that write and the row would do nothing. tlp-pd advertises all
    // three whatever the hardware, so this only bites under plain
    // power-profiles-daemon.
    readonly property var availableProfiles: profileOrder.filter(p => p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    function bucket(icons) {
        return icons[Math.min(icons.length - 1, Math.floor(root.level * icons.length))];
    }

    // Rounded to minutes before splitting, so 7199s reads 2h 0m, not 1h 60m.
    function duration(seconds) {
        const minutes = Math.round(seconds / 60);
        if (!(minutes > 0))
            return "";
        const h = Math.floor(minutes / 60);
        const m = minutes % 60;
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    function flow(arrow, seconds) {
        const left = root.duration(seconds);
        return Math.round(Math.abs(root.battery.changeRate)) + "W" + arrow + " " + root.percent + (left ? " " + left : "");
    }

    active: Env.hasBattery && (battery?.isLaptopBattery ?? false)
    // The level of a plugged battery is in the tooltip.
    text: status === "charging" ? bucket(chargingIcons) : status === "plugged" ? "󰚥" : bucket(dischargingIcons)
    // Low charge only matters when nothing is going to top it up.
    color: status !== "discharging" || level > 0.30 ? Theme.text : level > 0.15 ? Theme.warning : Theme.urgent
    tooltip: {
        if (!battery)
            return "";
        const lines = [status === "charging" ? flow("↑", battery.timeToFull) : status === "discharging" ? flow("↓", battery.timeToEmpty) : "Plugged in " + percent];
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

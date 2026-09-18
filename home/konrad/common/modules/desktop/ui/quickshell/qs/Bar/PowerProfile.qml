import QtQuick
import Quickshell.Services.UPower
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property var order: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]

    readonly property var icons: {
        const map = {};
        map[PowerProfile.PowerSaver] = "󰌪";
        map[PowerProfile.Balanced] = "󰾅";
        map[PowerProfile.Performance] = "󰓅";
        return map;
    }

    // tlp-pd does not always offer a performance profile, so cycling has to walk
    // the profiles that actually exist rather than the full list.
    readonly property var available: order.filter(p => p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    active: Env.hasPowerProfiles
    text: icons[PowerProfiles.profile] ?? icons[PowerProfile.Balanced]
    tooltip: "Power profile: " + PowerProfile.toString(PowerProfiles.profile)

    onLeftClicked: {
        const at = root.available.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = root.available[(at + 1) % root.available.length];
    }
}

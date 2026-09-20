pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
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

    // tlp-pd does not always offer a performance profile, so only the ones that
    // actually exist are offered.
    readonly property var available: order.filter(p => p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

    active: Env.hasPowerProfiles
    text: icons[PowerProfiles.profile] ?? icons[PowerProfile.Balanced]
    tooltip: "Power profile: " + PowerProfile.toString(PowerProfiles.profile)

    onLeftClicked: root.popupOpen = !root.popupOpen

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Dropdown {
                width: 220
                title: "Profile"
                current: PowerProfiles.profile
                options: root.available.map(p => ({
                            value: p,
                            label: PowerProfile.toString(p),
                            icon: root.icons[p]
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

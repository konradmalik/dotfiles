import QtQuick
import Quickshell
import qs.Common
import qs.Config
import qs.Ui

// The switches for the built-in panel and whatever is plugged in next to it.
// What they read and change lives in Displays, shared by every bar.
BarItem {
    id: root

    readonly property var layouts: [
        {
            value: "builtInOff",
            label: "Laptop display disabled",
            icon: "󰛧"
        },
        {
            value: "mirror",
            label: "Mirror display",
            icon: "󰆑"
        },
        {
            value: "extend",
            label: "Extend display",
            icon: "󰍺"
        }
    ]

    function labelOf(value) {
        return root.layouts.find(l => l.value === value)?.label ?? value;
    }

    active: Env.touchscreenDevice !== "" || Displays.canSwitchLayout
    text: "󰍹"
    // Muted while everything is left as the config set it, so the icon is worth
    // a look only once something here has been changed.
    color: Displays.touchscreen || Displays.layout !== "extend" ? Theme.text : Theme.muted
    tooltip: {
        const lines = [];
        if (Env.touchscreenDevice !== "")
            lines.push("Touchscreen " + (Displays.touchscreen ? "on" : "off"));
        if (Displays.canSwitchLayout)
            lines.push(root.labelOf(Displays.layout));
        return lines.join("\n");
    }

    onLeftClicked: root.popupOpen = !root.popupOpen

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: 240
                spacing: Theme.popupPadding

                Checkbox {
                    visible: Env.touchscreenDevice !== ""
                    label: "Touchscreen"
                    checked: Displays.touchscreen

                    onToggled: checked => Displays.touchscreen = checked
                }

                Dropdown {
                    visible: Displays.canSwitchLayout
                    title: "Displays"
                    options: root.layouts
                    current: Displays.layout

                    onPicked: value => Displays.setLayout(value)
                }
            }
        }
    }
}

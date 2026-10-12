pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Common
import qs.Config
import qs.Ui

// The laptop panel's profile, from the konrad.hyprland.monitors Nix module.
BarItem {
    id: root

    property string current: "default"

    // The same test as is_external in monitors.lua
    readonly property bool external: Hyprland.monitors.values.some(m => m.name !== Env.monitorPanel && m.description !== "")

    active: Env.hasMonitorProfiles && external
    text: "󰍺"
    tooltip: "Active profile: " + current

    onLeftClicked: root.popupOpen = !root.popupOpen

    // monitors.lua writes the name on every apply
    FileView {
        path: Env.hasMonitorProfiles ? Quickshell.env("XDG_RUNTIME_DIR") + "/" + Env.monitorStateFile : ""
        watchChanges: true
        printErrors: false

        onFileChanged: this.reload()
        onLoaded: {
            const name = this.text().trim();
            if (name)
                root.current = name;
        }
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
                current: root.current
                options: Env.monitorProfiles.map(p => ({
                            value: p,
                            label: p
                        }))

                expanded: true

                onPicked: value => {
                    Cmd.run([Env.monitors, value]);
                    root.popupOpen = false;
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Common
import qs.Config
import qs.Ui

// Controls for the laptop's own screen. Only the touchscreen so far.
//
// Hyprland has no way to read a device's enabled flag back -- get_config knows
// the global input:touchdevice keys but not the per-device ones -- so the shell
// owns the state rather than reflecting it. It starts out on whatever the
// config set, and is pushed back out whenever hyprland reloads and silently
// resets the device to that same config.
BarItem {
    id: root

    property bool touchscreen: Env.touchscreenEnabled

    function applyTouchscreen() {
        if (!root.active)
            return;
        // hyprctl takes the lua as one argument. The device name comes out of
        // the config rather than off the wire, so it needs no quoting beyond
        // being a string.
        Cmd.run([Env.hyprctl, "eval", 'hl.device({ name = "' + Env.touchscreenDevice + '", enabled = ' + (root.touchscreen ? "true" : "false") + " })"]);
    }

    active: Env.touchscreenDevice !== ""
    text: "󰍹"
    tooltip: "Touchscreen " + (touchscreen ? "on" : "off")

    onLeftClicked: root.popupOpen = !root.popupOpen

    // Covers a shell reload as well as a toggle: quickshell coming back up puts
    // the property at the config default, and hyprland has to agree with it.
    onTouchscreenChanged: root.applyTouchscreen()
    Component.onCompleted: root.applyTouchscreen()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "configreloaded")
                root.applyTouchscreen();
        }
    }

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: 180
                spacing: Theme.popupPadding

                Checkbox {
                    label: "Touchscreen"
                    checked: root.touchscreen

                    onToggled: checked => root.touchscreen = checked
                }
            }
        }
    }
}

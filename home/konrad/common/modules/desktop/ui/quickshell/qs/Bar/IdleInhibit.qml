import QtQuick
import Quickshell.Wayland
import qs.Common
import qs.Ui

BarItem {
    id: root

    required property var barWindow

    // A full, steaming mug while sleep is held off; an empty one otherwise.
    text: Shell.idleInhibited ? "󰅶" : "󰛊"
    color: Shell.idleInhibited ? Theme.warning : Theme.muted
    tooltip: Shell.idleInhibited ? "Idle inhibited" : "Idle allowed"

    onLeftClicked: Shell.idleInhibited = !Shell.idleInhibited

    IdleInhibitor {
        window: root.barWindow
        enabled: Shell.idleInhibited
    }
}

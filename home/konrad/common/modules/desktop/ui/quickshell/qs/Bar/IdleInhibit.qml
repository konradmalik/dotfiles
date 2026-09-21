import QtQuick
import Quickshell.Wayland
import qs.Common
import qs.Ui

BarItem {
    id: root

    required property var barWindow

    property bool inhibited: false

    // A full, steaming mug while sleep is held off; an empty one otherwise.
    text: inhibited ? "󰅶" : "󰛊"
    color: inhibited ? Theme.warning : Theme.muted
    tooltip: inhibited ? "Idle inhibited" : "Idle allowed"

    onLeftClicked: root.inhibited = !root.inhibited

    IdleInhibitor {
        window: root.barWindow
        enabled: root.inhibited
    }
}

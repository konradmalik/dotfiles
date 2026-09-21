import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar

        required property var modelData

        screen: modelData
        color: Theme.background
        implicitHeight: Theme.barHeight
        WlrLayershell.namespace: "quickshell-bar"

        anchors {
            top: true
            left: true
            right: true
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.barMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Menu {}

            Workspaces {}

            CurrentPlayer {}

            Player {}
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.itemSpacing

            NotificationsItem {}

            Clock {}

            Privacy {}
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.barMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Tray {}

            BluetoothItem {}

            Volume {}

            Tailscale {}

            NetworkItem {}

            Language {}

            Cpu {}

            Memory {}

            PowerProfile {}

            Battery {}

            Backlight {}

            Sunset {}

            IdleInhibit {
                barWindow: bar
            }

            PowerMenu {}
        }
    }
}

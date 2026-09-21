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

        // The clock is centred on the screen rather than sitting inside a
        // centred row, so whatever is put beside it cannot push the date off
        // centre.
        Clock {
            id: clock

            anchors.centerIn: parent
        }

        Row {
            anchors.right: clock.left
            anchors.rightMargin: Theme.itemSpacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            NotificationsItem {}

            IdleInhibit {
                barWindow: bar
            }
        }

        Row {
            anchors.left: clock.right
            anchors.leftMargin: Theme.itemSpacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

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

            Monitor {}

            PowerMenu {}
        }
    }
}

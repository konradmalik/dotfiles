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

        // Where you are and what is playing.
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.barMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Menu {}

            Workspaces {}
        }

        // The clock is centred on the screen rather than sitting inside a
        // centred row, so whatever is put beside it cannot push the date off
        // centre.
        Clock {
            id: clock

            anchors.centerIn: parent
        }

        // Indicators: something about this session is not in its usual state,
        // and the clock is where the eye already goes. The two that come and go
        // on their own sit nearest it.
        Row {
            anchors.right: clock.left
            anchors.rightMargin: Theme.itemSpacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Sunset {}

            IdleInhibit {
                barWindow: bar
            }

            NotificationsItem {}
        }

        Row {
            anchors.left: clock.right
            anchors.leftMargin: Theme.itemSpacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Media {}

            Privacy {}
        }

        // The machine, by subject, ending on the switch that turns it off:
        // other people's icons, then load, radios, sound, screen, power.
        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.barMargin
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.itemSpacing

            Tray {}

            BluetoothItem {}

            NetworkItem {}

            Tailscale {}

            Language {}

            Volume {}

            Backlight {}

            Monitor {}

            Cpu {}

            Memory {}

            PowerProfile {}

            Battery {}

            PowerMenu {}
        }
    }
}

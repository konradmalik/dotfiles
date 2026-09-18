pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import qs.Common
import qs.Config
import qs.Ui

Overlay {
    id: root

    property int selected: 0

    readonly property var entries: [
        {
            icon: "",
            label: "Lock",
            command: [Env.loginctl, "lock-session"]
        },
        {
            icon: "",
            label: "Suspend",
            command: [Env.systemctl, "suspend"]
        },
        {
            icon: "",
            label: "Log out",
            command: []
        },
        {
            icon: "",
            label: "Reboot",
            command: [Env.systemctl, "reboot"]
        },
        {
            icon: "",
            label: "Firmware",
            command: [Env.systemctl, "reboot", "--firmware-setup"]
        },
        {
            icon: "",
            label: "Shut down",
            command: [Env.systemctl, "-i", "poweroff"]
        }
    ]

    function activate(index) {
        const entry = root.entries[index];
        Shell.powerOpen = false;

        // Leaving the session is the compositor's job, and with a lua config it
        // is the only one of these that cannot be spelled as a plain command.
        if (entry.command.length === 0)
            Hyprland.dispatch("exit");
        else
            Cmd.run(entry.command);
    }

    shown: Shell.powerOpen
    onDismissed: Shell.powerOpen = false
    onShownChanged: if (shown)
        root.selected = 0

    Rectangle {
        implicitWidth: tiles.implicitWidth + 32
        implicitHeight: tiles.implicitHeight + 32
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        radius: Theme.popupRadius

        Keys.onLeftPressed: root.selected = (root.selected + root.entries.length - 1) % root.entries.length
        Keys.onRightPressed: root.selected = (root.selected + 1) % root.entries.length
        Keys.onReturnPressed: root.activate(root.selected)
        Keys.onEnterPressed: root.activate(root.selected)
        focus: true

        Row {
            id: tiles

            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: root.entries

                Rectangle {
                    id: tile

                    required property var modelData
                    required property int index

                    readonly property bool current: index === root.selected

                    implicitWidth: 110
                    implicitHeight: 110
                    radius: Theme.popupRadius
                    color: current ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: current ? Theme.accent : Theme.border

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.icon
                            color: tile.current ? Theme.accent : Theme.text
                            font.family: Theme.fontFamily
                            font.pointSize: Theme.fontSize * 2
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: tile.modelData.label
                            textFormat: Text.PlainText
                            color: Theme.text
                            font.family: Theme.popupFontFamily
                            font.pointSize: Theme.popupFontSize
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = tile.index
                        onClicked: root.activate(tile.index)
                    }
                }
            }
        }
    }
}

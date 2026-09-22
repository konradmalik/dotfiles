import QtQuick
import qs.Common
import qs.Ui

BarPopup {
    id: root

    Column {
        id: layout

        width: Theme.notificationWidth
        spacing: Theme.popupPadding

        Item {
            width: parent.width
            height: title.implicitHeight

            Text {
                id: title

                text: Notifs.history.length > 0 ? "NOTIFICATIONS (" + Notifs.history.length + ")" : "NOTIFICATIONS"
                textFormat: Text.PlainText
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupLabelFontSize
                color: Theme.muted
            }

            Text {
                anchors.right: parent.right
                anchors.baseline: title.baseline
                visible: Notifs.history.length > 0
                text: "Clear"
                textFormat: Text.PlainText
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupLabelFontSize
                color: clearMouse.containsMouse ? Theme.text : Theme.muted

                MouseArea {
                    id: clearMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Notifs.clear()
                }
            }
        }

        Text {
            width: parent.width
            visible: Notifs.history.length === 0
            height: implicitHeight + Theme.popupPadding * 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "No notifications"
            textFormat: Text.PlainText
            font.family: Theme.popupFontFamily
            font.pointSize: Theme.popupFontSize
            color: Theme.muted
        }

        Flickable {
            width: parent.width
            visible: Notifs.history.length > 0
            height: Math.min(list.implicitHeight, 520)
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list

                width: parent.width
                spacing: Theme.popupPadding

                Repeater {
                    model: Notifs.history

                    Card {
                        required property var modelData

                        notification: modelData
                        showActions: false

                        onDismissed: Notifs.forget(modelData)
                        onActivated: Notifs.forget(modelData)
                    }
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import qs.Common

PopupWindow {
    id: root

    required property Item anchorItem

    anchor.item: anchorItem
    anchor.rect.y: anchorItem ? anchorItem.height : 0
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"

    Rectangle {
        id: frame

        implicitWidth: Theme.notificationWidth + Theme.popupPadding * 2
        implicitHeight: Math.min(layout.implicitHeight + Theme.popupPadding * 2, 600)
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        radius: Theme.popupRadius

        Column {
            id: layout

            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.popupPadding

            Item {
                width: parent.width
                height: title.implicitHeight

                Text {
                    id: title

                    text: Notifs.history.length > 0 ? "Notifications (" + Notifs.history.length + ")" : "No notifications"
                    textFormat: Text.PlainText
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    anchors.right: parent.right
                    visible: Notifs.history.length > 0
                    text: "Clear"
                    textFormat: Text.PlainText
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize
                    color: clearMouse.containsMouse ? Theme.text : Theme.muted

                    MouseArea {
                        id: clearMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Notifs.clear()
                    }
                }
            }

            Flickable {
                width: parent.width
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
}

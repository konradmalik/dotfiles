import QtQuick
import qs.Common
import qs.Ui

BarPopup {
    id: root

    // Not Notifs.count: that one counts what is on screen, this one the list below.
    readonly property int historyCount: Notifs.history.length

    Column {
        id: layout

        width: Theme.notificationWidth
        spacing: Theme.popupPadding

        Item {
            width: parent.width
            height: title.implicitHeight

            Text {
                id: title

                text: root.historyCount > 0 ? "NOTIFICATIONS (" + root.historyCount + ")" : "NOTIFICATIONS"
                textFormat: Text.PlainText
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupLabelFontSize
                color: Theme.muted
            }

            Text {
                anchors.right: parent.right
                anchors.baseline: title.baseline
                visible: root.historyCount > 0
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

        // The same toggle the bar item does on middle click, spelled out: that
        // gesture is not something anyone finds by accident.
        PopupRow {
            onClicked: Notifs.dnd = !Notifs.dnd

            Text {
                id: dndGlyph

                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: Notifs.dnd ? "󰂛" : "󰂚"
                color: Notifs.dnd ? Theme.accent : Theme.text
                font.family: Theme.fontFamily
                font.pointSize: Theme.popupFontSize
            }

            Text {
                anchors.left: dndGlyph.right
                anchors.leftMargin: 6
                anchors.right: dndState.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: "Do not disturb"
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Notifs.dnd ? Theme.accent : Theme.text
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize
            }

            // Spelled out rather than a tick: a row that only reads as "on" when
            // something is there says nothing at all about what off looks like.
            Text {
                id: dndState

                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: Notifs.dnd ? "on" : "off"
                textFormat: Text.PlainText
                color: Notifs.dnd ? Theme.accent : Theme.muted
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize
            }
        }

        Text {
            width: parent.width
            visible: root.historyCount === 0
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
            visible: root.historyCount > 0
            height: Math.min(list.implicitHeight, Theme.notificationCenterMaxHeight)
            contentWidth: width
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

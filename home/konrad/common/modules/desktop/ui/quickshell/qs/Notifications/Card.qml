pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.Common

Rectangle {
    id: root

    required property var notification
    property bool showActions: true

    signal dismissed
    signal activated

    readonly property int horizontalPadding: 12
    readonly property int verticalPadding: 10
    readonly property int iconSize: 40
    readonly property bool hasIcon: notification.image !== "" || notification.appIcon !== ""

    readonly property color accentColor: {
        if (notification.urgency === NotificationUrgency.Critical)
            return Theme.urgent;
        if (notification.urgency === NotificationUrgency.Low)
            return Theme.low;
        return Theme.accent;
    }

    implicitWidth: Theme.notificationWidth
    implicitHeight: Math.min(layout.implicitHeight + verticalPadding * 2, Theme.notificationMaxHeight)
    color: Theme.background
    border.width: Theme.notificationBorder
    border.color: accentColor
    radius: Theme.radius
    clip: true

    Row {
        id: layout

        x: root.horizontalPadding
        y: root.verticalPadding
        width: parent.width - root.horizontalPadding * 2
        spacing: root.hasIcon ? 12 : 0

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            active: root.hasIcon
            width: active ? root.iconSize : 0
            height: active ? root.iconSize : 0
            sourceComponent: root.notification.image !== "" ? imageIcon : themeIcon
        }

        Column {
            width: parent.width - (root.hasIcon ? root.iconSize + parent.spacing : 0)
            spacing: 2

            Text {
                width: parent.width
                text: root.notification.summary
                textFormat: Text.PlainText
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize
                font.weight: Theme.emphasisWeight
                color: Theme.text
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: root.notification.body !== ""
                text: root.notification.body
                // Bodies arrive with the small html subset the spec allows,
                // which is what StyledText understands.
                textFormat: Text.StyledText
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize
                color: Theme.text
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            Item {
                width: parent.width
                height: actions.visible ? actions.implicitHeight + 6 : 0

                Row {
                    id: actions

                    y: 6
                    spacing: 8
                    visible: root.showActions && root.notification.actions.length > 0

                    Repeater {
                        model: root.notification.actions

                        Rectangle {
                            id: action

                            required property var modelData

                            implicitWidth: actionLabel.implicitWidth + 16
                            implicitHeight: actionLabel.implicitHeight + 8
                            color: actionMouse.containsMouse ? Theme.hover : "transparent"
                            border.width: 1
                            border.color: Theme.border
                            radius: Theme.popupRadius

                            Text {
                                id: actionLabel

                                anchors.centerIn: parent
                                text: action.modelData.text
                                textFormat: Text.PlainText
                                font.family: Theme.popupFontFamily
                                font.pointSize: Theme.popupFontSize - 1
                                color: Theme.text
                            }

                            MouseArea {
                                id: actionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    action.modelData.invoke();
                                    root.activated();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: imageIcon

        Image {
            source: root.notification.image
            sourceSize.width: root.iconSize
            sourceSize.height: root.iconSize
            fillMode: Image.PreserveAspectFit
        }
    }

    Component {
        id: themeIcon

        IconImage {
            source: Quickshell.iconPath(root.notification.appIcon, true)
            implicitSize: root.iconSize
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        // Sits under the action buttons so those keep their own clicks.
        z: -1

        onClicked: event => {
            if (event.button === Qt.RightButton) {
                root.dismissed();
                return;
            }

            const fallback = root.notification.actions.find(a => a.identifier === "default");
            if (fallback)
                fallback.invoke();
            root.activated();
        }
    }
}

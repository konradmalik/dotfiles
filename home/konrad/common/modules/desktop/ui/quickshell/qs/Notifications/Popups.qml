import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    screen: Shell.focusedScreen
    visible: Notifs.popups.length > 0
    color: "transparent"
    exclusiveZone: 0
    implicitHeight: Math.max(1, column.implicitHeight + column.anchors.topMargin * 2)
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    anchors {
        top: true
        left: true
        right: true
    }

    // Only the cards take clicks; the rest of the strip stays transparent to
    // the windows underneath.
    mask: Region {
        item: column
    }

    Column {
        id: column

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        spacing: 10

        // A plain array would rebuild every delegate whenever one popup is
        // dismissed, restarting the countdown on all the others. ScriptModel
        // diffs by identity so the surviving cards keep their timers.
        ScriptModel {
            id: visible

            values: Notifs.popups.slice(0, Theme.notificationMaxVisible)
        }

        Repeater {
            model: visible

            Card {
                id: card

                required property var modelData

                notification: modelData

                onDismissed: Notifs.dismiss(modelData)
                onActivated: Notifs.dismiss(modelData)

                // Zero means the sender asked for a notification that stays until
                // it is acted on; anything negative means "use the default".
                readonly property int timeout: modelData.expireTimeout < 0 ? Theme.notificationTimeout : modelData.expireTimeout

                Timer {
                    interval: card.timeout
                    running: card.timeout > 0
                    onTriggered: Notifs.dismiss(card.modelData)
                }
            }
        }
    }
}

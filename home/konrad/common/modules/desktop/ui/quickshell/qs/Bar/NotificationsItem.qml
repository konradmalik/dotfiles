pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Notifications
import qs.Ui

BarItem {
    id: root

    text: {
        const icon = Notifs.dnd ? "󰂛" : Notifs.count > 0 ? "󱅫" : "󰂚";
        return Notifs.count > 0 ? icon + " " + Notifs.count : icon;
    }
    tooltip: {
        if (Notifs.dnd)
            return "Do not disturb";
        if (Notifs.count === 0)
            return "No notifications";
        return Notifs.count + " notification(s)";
    }

    onLeftClicked: root.popupOpen = !root.popupOpen
    onRightClicked: Notifs.dismissAll()
    onMiddleClicked: Notifs.dnd = !Notifs.dnd
    onScrolledUp: Notifs.restore()
    onScrolledDown: Notifs.dismissOldest()

    LazyLoader {
        active: root.popupOpen

        Center {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false
        }
    }
}

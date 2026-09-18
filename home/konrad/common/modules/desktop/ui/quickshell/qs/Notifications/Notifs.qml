pragma Singleton
pragma ComponentBehavior: Bound
import QtQml
import Quickshell
import Quickshell.Services.Notifications
import qs.Common

Singleton {
    id: root

    property bool dnd: false
    property var popups: []
    property var dismissed: []

    // Transient notifications are volume popups and progress bars: worth
    // showing, not worth keeping. They still have to be tracked, because an
    // untracked one is destroyed the moment the handler returns, so they are
    // kept out of the history here instead.
    readonly property var history: [...server.trackedNotifications.values].reverse().filter(n => !n.transient)
    readonly property int count: popups.length

    function accept(notification) {
        notification.tracked = true;

        if (!root.dnd)
            root.popups = [notification].concat(root.popups);

        root.trim();
    }

    function trim() {
        const tracked = server.trackedNotifications.values;
        for (let i = 0; i < tracked.length - Theme.notificationHistory; i++)
            tracked[i].tracked = false;
    }

    function dismiss(notification) {
        if (!root.popups.includes(notification))
            return;
        root.popups = root.popups.filter(n => n !== notification);

        if (notification.transient) {
            notification.tracked = false;
            return;
        }

        root.dismissed = [notification].concat(root.dismissed).slice(0, Theme.notificationHistory);
    }

    function dismissOldest() {
        if (root.popups.length > 0)
            root.dismiss(root.popups[root.popups.length - 1]);
    }

    function dismissAll() {
        root.dismissed = root.popups.concat(root.dismissed).slice(0, Theme.notificationHistory);
        root.popups = [];
    }

    function restore() {
        if (root.dismissed.length === 0)
            return;
        const notification = root.dismissed[0];
        root.dismissed = root.dismissed.slice(1);
        if (!root.popups.includes(notification))
            root.popups = [notification].concat(root.popups);
    }

    function forget(notification) {
        root.popups = root.popups.filter(n => n !== notification);
        root.dismissed = root.dismissed.filter(n => n !== notification);
        notification.tracked = false;
    }

    function clear() {
        root.popups = [];
        root.dismissed = [];
        for (const notification of [...server.trackedNotifications.values])
            notification.tracked = false;
    }

    property NotificationServer server: NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => root.accept(notification)
    }

    // An application can withdraw a notification it sent; when it does, the
    // popup has to go with it rather than sit there until it times out.
    property Instantiator watcher: Instantiator {
        model: server.trackedNotifications

        delegate: QtObject {
            id: watched

            required property var modelData

            property Connections conn: Connections {
                target: watched.modelData

                function onClosed() {
                    root.popups = root.popups.filter(n => n !== watched.modelData);
                    root.dismissed = root.dismissed.filter(n => n !== watched.modelData);
                }
            }
        }
    }
}

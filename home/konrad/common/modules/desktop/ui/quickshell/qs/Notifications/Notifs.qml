pragma Singleton
pragma ComponentBehavior: Bound
import QtQml
import Quickshell
import Quickshell.Services.Notifications
import qs.Common

Singleton {
    id: root

    property bool dnd: false

    // What is on screen right now. Quickshell has no popup of its own: `tracked`
    // decides what stays in the server's list, that list is the history, and
    // what gets drawn on top of it is the shell's own business.
    property var popups: []

    // Transient notifications are volume popups and progress bars: worth
    // showing, not worth keeping.
    readonly property var history: [...server.trackedNotifications.values].reverse().filter(n => !n.transient)
    readonly property int count: popups.length

    function accept(notification) {
        // An untracked notification is destroyed the moment this returns.
        notification.tracked = true;

        if (!root.dnd)
            root.popups = [notification].concat(root.popups);

        // Keep the history bounded; the oldest drop off the end. The copy
        // matters: `values` is the live list, and untracking one shifts every
        // index after it out from under the loop.
        const tracked = [...server.trackedNotifications.values];
        for (let i = 0; i < tracked.length - Theme.notificationHistory; i++)
            tracked[i].tracked = false;
    }

    // Taking a popup off screen deliberately does not call notification.dismiss():
    // that would close it, and a closed notification leaves the server's list,
    // which is the history. Transient ones are not kept, so they go straight out.
    function dismiss(notification) {
        root.popups = root.popups.filter(n => n !== notification);

        if (notification.transient)
            notification.tracked = false;
    }

    function dismissOldest() {
        if (root.popups.length > 0)
            root.dismiss(root.popups[root.popups.length - 1]);
    }

    function dismissAll() {
        for (const notification of [...root.popups])
            root.dismiss(notification);
    }

    function forget(notification) {
        root.popups = root.popups.filter(n => n !== notification);
        notification.tracked = false;
    }

    function clear() {
        root.popups = [];
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
                }
            }
        }
    }
}

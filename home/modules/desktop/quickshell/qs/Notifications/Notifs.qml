pragma Singleton
pragma ComponentBehavior: Bound
import QtQml
import Quickshell
import Quickshell.Services.Notifications
import qs.Common

Singleton {
    id: root

    // Silence takes effect immediately: whatever is on screen when it goes on
    // is a disturbance too.
    property bool dnd: false
    onDndChanged: if (root.dnd)
        root.dismissAll()

    // What is waiting to be shown. Quickshell has no popup of its own: `tracked`
    // decides what stays in the server's list, that list is the history, and
    // what gets drawn on top of it is the shell's own business.
    property var popups: []

    // Only so many fit on screen; the rest queue up behind them and start their
    // countdown once they get there. One place decides which, because both the
    // strip that draws them and dismissOldest have to agree on what is up.
    readonly property var visiblePopups: popups.slice(0, Theme.notificationMaxVisible)

    // Transient notifications are volume popups and progress bars: worth
    // showing, not worth keeping.
    readonly property var history: [...server.trackedNotifications.values].reverse().filter(n => !n.transient)
    readonly property int count: popups.length

    function accept(notification) {
        // An untracked notification is destroyed the moment this returns.
        notification.tracked = true;

        if (!root.dnd)
            root.popups = [notification].concat(root.popups);

        // Keep the history bounded; the oldest drop off the end. Counted the way
        // history counts it, so a burst of transient ones cannot push the real
        // notifications out early. The copy matters: `values` is the live list,
        // and untracking one shifts every index after it out from under the
        // loop. forget() rather than a bare untrack, because an untracked
        // notification is destroyed and must not be left sitting in popups.
        const kept = [...server.trackedNotifications.values].filter(n => !n.transient);
        for (let i = 0; i < kept.length - Theme.notificationHistory; i++)
            root.forget(kept[i]);
    }

    // Taking a popup off screen deliberately does not call notification.dismiss():
    // that would close it, and a closed notification leaves the server's list,
    // which is the history. Transient ones are not kept, so they go straight out.
    function dismiss(notification) {
        root.popups = root.popups.filter(n => n !== notification);

        if (notification.transient)
            notification.tracked = false;
    }

    // The oldest one on screen, not the oldest queued: a scroll that dismissed
    // something nobody can see would look like it did nothing.
    function dismissOldest() {
        const shown = root.visiblePopups;
        if (shown.length > 0)
            root.dismiss(shown[shown.length - 1]);
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

        delegate: Connections {
            id: watched

            required property var modelData

            target: modelData

            function onClosed() {
                root.popups = root.popups.filter(n => n !== watched.modelData);
            }
        }
    }
}

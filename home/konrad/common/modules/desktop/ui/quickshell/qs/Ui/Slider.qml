import QtQuick
import qs.Common

// Qt Quick Controls' Slider would pull in a whole control style for what is a
// track, a fill and a handle, so these are drawn directly.
Item {
    id: root

    property real value: 0
    property color fill: Theme.accent

    readonly property real clamped: Math.max(0, Math.min(1, value))

    signal moved(real value)
    signal stepped(int direction)

    implicitWidth: 180
    implicitHeight: 16

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        color: Theme.border

        Rectangle {
            width: handle.x + handle.width / 2
            height: parent.height
            radius: parent.radius
            color: root.fill
        }
    }

    Rectangle {
        id: handle

        x: (track.width - width) * root.clamped
        anchors.verticalCenter: parent.verticalCenter
        width: root.height
        height: root.height
        radius: width / 2
        color: root.fill
        border.width: 2
        border.color: Theme.background
    }

    MouseArea {
        id: mouse

        anchors.fill: parent

        // The handle's centre only travels between its own half-widths, so the
        // pointer maps onto that shorter span rather than onto the full track.
        function pick(x) {
            const span = track.width - handle.width;
            if (span > 0)
                root.moved(Math.max(0, Math.min(1, (x - handle.width / 2) / span)));
        }

        onPressed: event => mouse.pick(event.x)
        onPositionChanged: event => mouse.pick(event.x)

        // A wheel reports 120-unit steps and a touchpad reports pixels, so only
        // the sign of the delta is meaningful across both.
        onWheel: event => {
            const dy = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
            if (dy > 0)
                root.stepped(1);
            else if (dy < 0)
                root.stepped(-1);
        }
    }
}

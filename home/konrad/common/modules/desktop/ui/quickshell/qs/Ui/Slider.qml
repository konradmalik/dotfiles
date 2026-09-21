import QtQuick
import qs.Common

// Not Qt Quick Controls' Slider, even though the calendar now brings Controls
// in. That one owns its value and writes to it as you drag, which drops the
// binding that put it there. Every slider here shows a value the system owns --
// brightness moves under the hyprland keys, volume under pipewire -- so the
// parent stays the source of truth and this only ever reports a request.
Item {
    id: root

    property real value: 0
    property real step: 0.05
    property color fill: Theme.accent

    readonly property real position: root.clamp(value)

    // Dragging and the wheel both report through here, so a caller only has one
    // thing to handle.
    signal moved(real value)

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    implicitWidth: 180
    implicitHeight: 16

    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        // Not Theme.border: the popup's own background is base00 and the border
        // colour is close enough to it that an empty track all but disappears.
        color: Theme.low

        Rectangle {
            width: handle.x + handle.width / 2
            height: parent.height
            radius: parent.radius
            color: root.fill
        }
    }

    Rectangle {
        id: handle

        x: (track.width - width) * root.position
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
                root.moved(root.clamp((x - handle.width / 2) / span));
        }

        onPressed: event => mouse.pick(event.x)
        onPositionChanged: event => mouse.pick(event.x)

        // A wheel reports 120-unit steps and a touchpad reports pixels, so only
        // the sign of the delta is meaningful across both.
        onWheel: event => {
            const dy = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
            if (dy !== 0)
                root.moved(root.clamp(root.position + (dy > 0 ? root.step : -root.step)));
        }
    }
}

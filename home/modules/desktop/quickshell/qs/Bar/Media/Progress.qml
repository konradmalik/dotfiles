pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui

// How far into the track the player is, with a slider to move through it and
// the elapsed and total time under it. Players that cannot report both a
// position and a length go without.
Column {
    id: root

    required property var player

    readonly property bool available: player.positionSupported && player.lengthSupported && player.length > 0

    function clock(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        const h = Math.floor(total / 3600);
        const m = Math.floor(total % 3600 / 60);
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${s}` : `${m}:${s}`;
    }

    width: parent.width
    spacing: 2
    visible: available

    // The position is only re-read when told to, so while the track plays it
    // gets told once a second.
    Timer {
        running: root.visible && root.player.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        triggeredOnStart: true

        onTriggered: root.player.positionChanged()
    }

    // Live, but rationed: Spotify given a seek per pixel of a drag stops
    // answering seeks at all, and stops reporting where it is, until it is next
    // paused. So one seek goes out at once, the rest of the drag waits here, and
    // whatever the handle was last moved to goes out when the wait is up.
    Timer {
        id: throttle

        property real pending: -1

        interval: 250

        function request(value) {
            if (running) {
                pending = value;
                return;
            }
            root.player.position = value * root.player.length;
            pending = -1;
            start();
        }

        onTriggered: if (pending >= 0)
            request(pending)
    }

    Slider {
        id: seek

        width: parent.width
        value: throttle.pending >= 0 ? throttle.pending : root.player.position / root.player.length
        enabled: root.player.canSeek
        fill: enabled ? Theme.accent : Theme.muted

        onMoved: value => throttle.request(value)
    }

    Item {
        width: parent.width
        height: elapsed.implicitHeight

        Text {
            id: elapsed

            anchors.left: parent.left
            text: root.clock(seek.value * root.player.length)
            textFormat: Text.PlainText
            color: Theme.muted
            font.family: Theme.popupFontFamily
            font.pointSize: Theme.popupLabelFontSize
        }

        Text {
            anchors.right: parent.right
            text: root.clock(root.player.length)
            textFormat: Text.PlainText
            color: Theme.muted
            font.family: Theme.popupFontFamily
            font.pointSize: Theme.popupLabelFontSize
        }
    }
}

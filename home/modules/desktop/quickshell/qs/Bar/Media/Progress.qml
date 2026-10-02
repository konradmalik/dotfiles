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

    // Not live: seeking on every pixel of a drag would stutter the audio, so
    // the seek lands on release and the clock follows the handle until then.
    Slider {
        id: seek

        width: parent.width
        value: root.player.position / root.player.length
        live: false
        enabled: root.player.canSeek
        fill: enabled ? Theme.accent : Theme.muted

        onMoved: value => root.player.position = value * root.player.length
    }

    Item {
        width: parent.width
        height: elapsed.implicitHeight

        Text {
            id: elapsed

            anchors.left: parent.left
            text: root.clock(seek.dragging ? seek.position * root.player.length : root.player.position)
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

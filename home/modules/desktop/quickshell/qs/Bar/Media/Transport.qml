pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui

// Previous, play/pause and next, as three equal buttons across the popup.
Row {
    id: root

    required property var player

    readonly property real buttonWidth: (width - spacing * 2) / 3

    width: parent.width
    spacing: 8

    // `enabled` is the Item's own: a transport button the player cannot serve
    // goes grey and stops taking clicks.
    component Button: PopupRow {
        id: button

        required property string glyph

        // Not `parent`: a PopupRow puts what it is given inside its own body
        // item, so the button has to be named to be reached from in there.
        Text {
            anchors.centerIn: parent
            text: button.glyph
            color: button.enabled ? Theme.text : Theme.muted
            font.family: Theme.fontFamily
            font.pointSize: Theme.popupFontSize
        }
    }

    Button {
        width: root.buttonWidth
        glyph: ""
        enabled: root.player.canGoPrevious

        onClicked: root.player.previous()
    }

    // Shows what pressing it would do, which is the other one.
    Button {
        width: root.buttonWidth
        glyph: root.player.playbackState === MprisPlaybackState.Playing ? "" : ""
        enabled: root.player.canTogglePlaying

        onClicked: root.player.togglePlaying()
    }

    Button {
        width: root.buttonWidth
        glyph: ""
        enabled: root.player.canGoNext

        onClicked: root.player.next()
    }
}

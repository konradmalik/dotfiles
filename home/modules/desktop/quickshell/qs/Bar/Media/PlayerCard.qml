pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui

// One player's block in the media popup, top to bottom: which app it is, what
// it is playing, the transport buttons, then progress and volume for players
// that report them.
Column {
    id: root

    required property var player

    readonly property bool playing: player.playbackState === MprisPlaybackState.Playing

    readonly property var appIcons: ({
            spotify: "",
            firefox: "",
            discord: "󰙯",
            mpv: ""
        })

    function appIcon(identity) {
        const name = (identity ?? "").toLowerCase();
        for (const key in root.appIcons)
            if (name.includes(key))
                return root.appIcons[key];
        return "";
    }

    width: parent.width
    spacing: 2

    // The app, with the meter hung off the left of its centred name. The
    // padding is reserved on both sides so the name stays centred either way.
    Text {
        id: label

        width: parent.width
        leftPadding: meter.width + 6
        rightPadding: leftPadding
        text: [root.appIcon(root.player.identity), root.player.identity].filter(p => p).join(" ")
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: root.playing ? Theme.accent : Theme.muted
        font.family: Theme.fontFamily
        font.pointSize: Theme.popupLabelFontSize

        Meter {
            id: meter

            x: (label.width - label.contentWidth) / 2 - width - 6
            anchors.verticalCenter: parent.verticalCenter
            visible: root.playing
        }
    }

    Text {
        width: parent.width
        text: root.player.trackTitle || "Nothing playing"
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: Theme.text
        font.family: Theme.popupFontFamily
        font.pointSize: Theme.popupFontSize
        font.weight: Theme.emphasisWeight
    }

    Text {
        width: parent.width
        visible: text !== ""
        text: root.player.trackArtist ?? ""
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: Theme.muted
        font.family: Theme.popupFontFamily
        font.pointSize: Theme.popupFontSize
    }

    Item {
        width: parent.width
        height: 6
    }

    Transport {
        player: root.player
    }

    Column {
        width: parent.width
        topPadding: 6
        spacing: 2
        visible: progress.available || volume.available

        Progress {
            id: progress

            player: root.player
        }

        Row {
            id: volume

            readonly property bool available: root.player.volumeSupported && root.player.canControl

            width: parent.width
            spacing: 8
            visible: available

            Text {
                id: volumeIcon

                anchors.verticalCenter: parent.verticalCenter
                text: root.player.volume > 0 ? "󰕾" : "󰖁"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pointSize: Theme.popupFontSize
            }

            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - volumeIcon.width - parent.spacing
                value: root.player.volume

                onMoved: value => root.player.volume = value
            }
        }
    }
}

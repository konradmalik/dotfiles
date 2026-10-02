pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui

// Now playing, the way a menu bar does it: one icon saying whether anything is
// going, every player and its track on hover, and a block of controls per
// player behind a click. The bar keeps the same width whatever the track is
// called, and nothing has to be "selected" before it can be driven.
BarItem {
    id: root

    readonly property var player: Players.current

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

    // What the player is doing. The three glyphs have to render at the same
    // width: the popup hangs centred under this item, so a narrower one would
    // nudge it sideways on every play/pause.
    function stateIcon(candidate) {
        if (candidate?.playbackState === MprisPlaybackState.Playing)
            return "󰐌";
        if (candidate?.playbackState === MprisPlaybackState.Paused)
            return "󰏥";
        return "󰙦";
    }

    // What pressing the button would do, which is the other one.
    function toggleIcon(candidate) {
        return candidate?.playbackState === MprisPlaybackState.Playing ? "" : "";
    }

    function trackOf(candidate) {
        const parts = [candidate.trackArtist, candidate.trackTitle].filter(p => p);
        return parts.join(" - ") || "nothing playing";
    }

    function clock(seconds) {
        const total = Math.max(0, Math.floor(seconds));
        const h = Math.floor(total / 3600);
        const m = Math.floor(total % 3600 / 60);
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${s}` : `${m}:${s}`;
    }

    active: player !== null
    text: root.stateIcon(root.player)
    // Every player, not just the one the icon is reporting, so the hover
    // answers "what else is going?" without opening anything.
    tooltip: Players.all.map(candidate => (candidate === root.player ? "* " : "  ") + candidate.identity + "  " + root.trackOf(candidate)).join("\n")

    onLeftClicked: root.popupOpen = !root.popupOpen
    onScrolledUp: if (player?.canGoNext)
        player.next()
    onScrolledDown: if (player?.canGoPrevious)
        player.previous()

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

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: Theme.popupWidth
                spacing: Theme.popupPadding

                // One block per player rather than a picker: every player is
                // driven where it is, so there is nothing to switch to first.
                Repeater {
                    model: Players.all

                    Column {
                        id: block

                        required property var modelData
                        required property int index

                        width: parent.width
                        spacing: 2

                        // Sits between blocks, so the first one goes without.
                        Item {
                            width: parent.width
                            height: Theme.popupPadding
                            visible: block.index > 0

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }
                        }

                        Text {
                            id: label

                            readonly property bool playing: block.modelData.playbackState === MprisPlaybackState.Playing

                            width: parent.width
                            leftPadding: meter.width + 6
                            rightPadding: leftPadding
                            text: [root.appIcon(block.modelData.identity), block.modelData.identity].filter(p => p).join(" ")
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: label.playing ? Theme.accent : Theme.muted
                            font.family: Theme.fontFamily
                            font.pointSize: Theme.popupLabelFontSize

                            Row {
                                id: meter

                                x: (label.width - label.contentWidth) / 2 - width - 6
                                anchors.verticalCenter: parent.verticalCenter
                                height: 10
                                spacing: 2
                                visible: label.playing

                                Repeater {
                                    model: [320, 450, 380]

                                    Rectangle {
                                        id: bar

                                        required property int modelData

                                        anchors.bottom: meter.bottom
                                        width: 3
                                        color: Theme.accent

                                        SequentialAnimation on height {
                                            running: label.playing
                                            loops: Animation.Infinite

                                            NumberAnimation {
                                                to: meter.height
                                                duration: bar.modelData
                                            }
                                            NumberAnimation {
                                                to: 2
                                                duration: bar.modelData
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: block.modelData.trackTitle || "Nothing playing"
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
                            text: block.modelData.trackArtist ?? ""
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

                        Row {
                            id: transport

                            width: parent.width
                            spacing: 8

                            readonly property real buttonWidth: (width - spacing * 2) / 3

                            Button {
                                width: transport.buttonWidth
                                glyph: ""
                                enabled: block.modelData.canGoPrevious

                                onClicked: block.modelData.previous()
                            }

                            Button {
                                width: transport.buttonWidth
                                glyph: root.toggleIcon(block.modelData)
                                enabled: block.modelData.canTogglePlaying

                                onClicked: block.modelData.togglePlaying()
                            }

                            Button {
                                width: transport.buttonWidth
                                glyph: ""
                                enabled: block.modelData.canGoNext

                                onClicked: block.modelData.next()
                            }
                        }

                        Timer {
                            running: progress.visible && block.modelData.playbackState === MprisPlaybackState.Playing
                            interval: 1000
                            repeat: true
                            triggeredOnStart: true

                            onTriggered: block.modelData.positionChanged()
                        }

                        Column {
                            width: parent.width
                            topPadding: 6
                            spacing: 2
                            visible: progress.visible || volume.visible

                            Column {
                                id: progress

                                width: parent.width
                                spacing: 2
                                visible: block.modelData.positionSupported && block.modelData.lengthSupported && block.modelData.length > 0

                                Slider {
                                    id: seek

                                    width: parent.width
                                    value: block.modelData.position / block.modelData.length
                                    live: false
                                    enabled: block.modelData.canSeek
                                    fill: enabled ? Theme.accent : Theme.muted

                                    onMoved: value => block.modelData.position = value * block.modelData.length
                                }

                                Item {
                                    width: parent.width
                                    height: elapsed.implicitHeight

                                    Text {
                                        id: elapsed

                                        anchors.left: parent.left
                                        text: root.clock(seek.dragging ? seek.position * block.modelData.length : block.modelData.position)
                                        textFormat: Text.PlainText
                                        color: Theme.muted
                                        font.family: Theme.popupFontFamily
                                        font.pointSize: Theme.popupLabelFontSize
                                    }

                                    Text {
                                        anchors.right: parent.right
                                        text: root.clock(block.modelData.length)
                                        textFormat: Text.PlainText
                                        color: Theme.muted
                                        font.family: Theme.popupFontFamily
                                        font.pointSize: Theme.popupLabelFontSize
                                    }
                                }
                            }

                            Row {
                                id: volume

                                width: parent.width
                                spacing: 8
                                visible: block.modelData.volumeSupported && block.modelData.canControl

                                Text {
                                    id: volumeIcon

                                    anchors.verticalCenter: parent.verticalCenter
                                    text: block.modelData.volume > 0 ? "󰕾" : "󰖁"
                                    color: Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pointSize: Theme.popupFontSize
                                }

                                Slider {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - volumeIcon.width - parent.spacing
                                    value: block.modelData.volume

                                    onMoved: value => block.modelData.volume = value
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

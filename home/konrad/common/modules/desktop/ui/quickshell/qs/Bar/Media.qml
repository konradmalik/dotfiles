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

    // What the player is doing.
    function stateIcon(candidate) {
        if (candidate?.playbackState === MprisPlaybackState.Playing)
            return "";
        if (candidate?.playbackState === MprisPlaybackState.Paused)
            return "";
        return "";
    }

    // What pressing the button would do, which is the other one.
    function toggleIcon(candidate) {
        return candidate?.playbackState === MprisPlaybackState.Playing ? "" : "";
    }

    function trackOf(candidate) {
        const parts = [candidate.trackArtist, candidate.trackTitle].filter(p => p);
        return parts.join(" - ") || "nothing playing";
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
                            width: parent.width
                            text: [root.appIcon(block.modelData.identity), block.modelData.identity].filter(p => p).join(" ")
                            textFormat: Text.PlainText
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Theme.muted
                            font.family: Theme.fontFamily
                            font.pointSize: Theme.popupFontSize - 2
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
                            font.bold: true
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
                    }
                }
            }
        }
    }
}

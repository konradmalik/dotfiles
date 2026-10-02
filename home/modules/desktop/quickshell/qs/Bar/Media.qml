pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui
import "Media"

// Now playing, the way a menu bar does it: one icon saying whether anything is
// going, every player and its track on hover, and a block of controls per
// player behind a click. The bar keeps the same width whatever the track is
// called, and nothing has to be "selected" before it can be driven.
//
// The block itself, and the pieces it is made of, live in Media/.
BarItem {
    id: root

    readonly property var player: Players.current

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

    component Divider: Item {
        width: parent.width
        height: Theme.popupPadding

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 1
            color: Theme.border
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
                        id: entry

                        required property var modelData
                        required property int index

                        width: parent.width
                        spacing: 2

                        // Sits between blocks, so the first one goes without.
                        Divider {
                            visible: entry.index > 0
                        }

                        PlayerCard {
                            player: entry.modelData
                        }
                    }
                }
            }
        }
    }
}

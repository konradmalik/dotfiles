import QtQuick
import Quickshell.Services.Mpris
import qs.Common
import qs.Ui

BarItem {
    id: root

    readonly property var player: Players.current

    readonly property string label: {
        if (!player)
            return "";
        const parts = [player.trackArtist, player.trackTitle].filter(p => p);
        const joined = parts.join(" - ");
        return joined.length > 50 ? joined.substring(0, 49) + "…" : joined;
    }

    readonly property string icon: {
        if (player?.playbackState === MprisPlaybackState.Playing)
            return "";
        if (player?.playbackState === MprisPlaybackState.Paused)
            return "";
        return "";
    }

    active: player !== null && label !== ""
    text: icon + " " + label
    tooltip: player ? [player.trackTitle, player.trackArtist, player.trackAlbum].filter(p => p).join("\n") : ""

    onLeftClicked: if (player?.canTogglePlaying)
        player.togglePlaying()
    onScrolledUp: if (player?.canGoNext)
        player.next()
    onScrolledDown: if (player?.canGoPrevious)
        player.previous()
}

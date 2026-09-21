pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

// MPRIS names no current player, so the shell picks one: whatever is actually
// playing, else whatever is there. Nothing selects it by hand -- every player
// is driven where it is shown, so the only thing this has to answer is which
// one the bar reports on.
Singleton {
    id: root

    // playerctld is a proxy that mirrors whichever player is active, so counting
    // it would show every player twice and let the cursor land on a duplicate.
    readonly property var all: Mpris.players.values.filter(p => !p.dbusName.endsWith(".playerctld"))
    readonly property int count: all.length

    readonly property var current: root.all.find(p => p.playbackState === MprisPlaybackState.Playing) ?? root.all[0] ?? null
}

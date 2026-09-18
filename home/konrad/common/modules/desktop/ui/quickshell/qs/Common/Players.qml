pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

// MPRIS names no current player, so the bar keeps its own cursor. It holds a
// dbus name rather than an index: players come and go, and an index would
// silently start pointing at a different one.
Singleton {
    id: root

    property string selected: ""

    // playerctld is a proxy that mirrors whichever player is active, so counting
    // it would show every player twice and let the cursor land on a duplicate.
    readonly property var all: Mpris.players.values.filter(p => !p.dbusName.endsWith(".playerctld"))
    readonly property int count: all.length

    readonly property var current: {
        const players = root.all;
        if (players.length === 0)
            return null;
        return players.find(p => p.dbusName === root.selected) ?? players[0];
    }

    function shift(step) {
        const players = root.all;
        if (players.length === 0)
            return;
        const at = players.indexOf(root.current);
        const next = (at + step + players.length) % players.length;
        root.selected = players[next].dbusName;
    }
}

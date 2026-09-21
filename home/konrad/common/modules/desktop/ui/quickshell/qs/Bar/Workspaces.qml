pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import qs.Common
import qs.Ui

Row {
    id: root

    // Five slots are always on the bar; anything else Hyprland reports is
    // appended.
    readonly property var ids: {
        const out = [1, 2, 3, 4, 5];
        for (const ws of Hyprland.workspaces.values)
            if (ws.id > 0 && !out.includes(ws.id))
                out.push(ws.id);
        out.sort((a, b) => a - b);
        return out;
    }

    function workspace(id) {
        return Hyprland.workspaces.values.find(w => w.id === id) ?? null;
    }

    // A workspace with no windows on it does not exist as far as Hyprland is
    // concerned, so there is nothing to activate and the switch has to go
    // through a dispatch instead.
    function goTo(id) {
        const ws = root.workspace(id);
        if (ws)
            ws.activate();
        else
            Hyprland.dispatch('hl.dsp.focus({ workspace = "' + id + '" })');
    }

    function step(delta) {
        const focused = Hyprland.focusedWorkspace?.id ?? 1;
        const at = root.ids.indexOf(focused);
        if (at < 0)
            return;
        const next = at + delta;
        if (next >= 0 && next < root.ids.length)
            root.goTo(root.ids[next]);
    }

    Repeater {
        model: root.ids

        BarItem {
            id: item

            required property int modelData

            readonly property var ws: root.workspace(modelData)
            readonly property bool focused: Hyprland.focusedWorkspace?.id === modelData
            readonly property bool occupied: (ws?.toplevels.values.length ?? 0) > 0

            padding: 4
            text: focused ? "󱓻" : modelData === 10 ? "0" : String(modelData)
            color: focused ? Theme.accentAlt : Theme.text
            opacity: focused || occupied ? 1 : 0.5

            onLeftClicked: root.goTo(modelData)
            onScrolledUp: root.step(1)
            onScrolledDown: root.step(-1)
        }
    }
}

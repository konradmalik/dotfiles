pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Config

// The built-in panel, whatever is plugged in next to it, and the touchscreen on
// the panel itself. One copy for the whole shell: there is one machine behind
// these switches, however many bars are showing them.
//
// Hyprland has no way to read a device's enabled flag back -- get_config knows
// the global input:touchdevice keys but not the per-device ones -- so the
// touchscreen state is owned here rather than reflected. It starts out on what
// the config set, and is pushed back out whenever hyprland reloads and silently
// resets the device to it. The display layout is the other way round: hyprland
// does report that, so it is read rather than kept.
Singleton {
    id: root

    property bool touchscreen: Env.touchscreenEnabled

    // Filled from `hyprctl monitors all`, because plain `hyprctl monitors`
    // lists only what is currently lit: a monitor that is off or mirroring
    // another one drops out of it, and those are the two states this exists to
    // name and undo.
    property var builtIn: null
    property var externals: []

    // The layout asked for, held until hyprland has reloaded and is back at the
    // config's own.
    property string wanted: ""

    // Every layout is about what the built-in panel does next to an external
    // one, so a machine missing either half has nothing to choose.
    readonly property bool canSwitchLayout: root.builtIn !== null && root.externals.length > 0

    readonly property string layout: {
        if (root.builtIn?.disabled)
            return "builtInOff";
        if (root.externals.some(o => o.mirrorOf !== "none"))
            return "mirror";
        return "extend";
    }

    // The connector name is where the kernel says which panel is built in, and
    // hyprland passes it through untouched.
    function isBuiltIn(name) {
        return /^(eDP|LVDS|DSI)/i.test(name);
    }

    // hyprctl takes the lua as one argument. Nothing waits for an answer: what
    // a write actually did is read back rather than assumed, because a monitor
    // rule only lands on hyprland's next reconfigure and can quietly do
    // nothing.
    function run(lua) {
        Quickshell.execDetached([Env.hyprctl, "eval", lua]);
        settle.restart();
    }

    function applyTouchscreen() {
        if (Env.touchscreenDevice === "")
            return;
        // The device name comes out of the config rather than off the wire, so
        // it needs no quoting beyond being a string.
        root.run('hl.device({ name = "' + Env.touchscreenDevice + '", enabled = ' + (root.touchscreen ? "true" : "false") + " })");
    }

    function rule(output, keys) {
        return 'hl.monitor({ output = "' + output + '", ' + keys + ' })';
    }

    // Switching never tries to undo the last layout. A rule is merged into
    // whatever the output already carries, and hyprland will not reliably take
    // a mirror back off once it is on -- `mirror = "none"` is accepted and then
    // ignored. So a switch reloads the config, which is plain extend with
    // nothing mirrored and nothing off, and the new layout is added on top of
    // that once hyprland says the reload is through.
    function setLayout(value) {
        root.wanted = value;
        Quickshell.execDetached([Env.hyprctl, "reload"]);
    }

    function applyWanted() {
        const value = root.wanted;
        root.wanted = "";

        // Extend needs nothing on top: the reload already is it.
        if (!root.builtIn || value === "" || value === "extend")
            return;

        const name = root.builtIn.name;
        const rules = value === "builtInOff" ? [root.rule(name, "disabled = true")] : root.externals.map(o => root.rule(o.name, 'mirror = "' + name + '"'));
        root.run(rules.join(" "));
    }

    function rescan() {
        if (!scan.running)
            scan.running = true;
    }

    onTouchscreenChanged: root.applyTouchscreen()

    Component.onCompleted: {
        root.applyTouchscreen();
        root.rescan();
    }

    property Connections hyprland: Connections {
        target: Hyprland

        // Hyprland announces a monitor that comes or goes, but says nothing at
        // all when one starts or stops mirroring -- that case is covered by the
        // read-back after a write.
        function onRawEvent(event) {
            if (event.name === "configreloaded") {
                root.applyTouchscreen();
                root.applyWanted();
                root.rescan();
            } else if (event.name.startsWith("monitor")) {
                root.rescan();
            }
        }
    }

    property Timer settle: Timer {
        id: settle

        interval: 300
        onTriggered: root.rescan()
    }

    property Process scan: Process {
        id: scan

        command: [Env.hyprctl, "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let outputs;
                try {
                    outputs = JSON.parse(this.text);
                } catch (e) {
                    // Hyprland mid-reconfigure can answer with nothing usable.
                    // The last good answer stands until the next scan, which
                    // beats a blank list -- that would read as "the external is
                    // gone" and undo a layout that is fine.
                    return;
                }

                root.builtIn = outputs.find(o => root.isBuiltIn(o.name)) ?? null;
                root.externals = outputs.filter(o => !root.isBuiltIn(o.name));

                // Losing the last external while the panel is off would leave
                // the menu that could turn it back on sitting on a screen
                // nobody can see.
                if (root.builtIn?.disabled && root.externals.length === 0)
                    root.setLayout("extend");
            }
        }
    }
}

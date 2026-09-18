import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    property string layout: ""

    // Hyprland reports the full keymap description ("Polish"), and the bar has
    // room for a code, so the label is the first word cut to two characters.
    text: layout === "" ? "" : layout.split(" ")[0].substring(0, 2).toUpperCase()
    tooltip: layout

    onLeftClicked: Cmd.run([Env.hyprctl, "switchxkblayout", "all", "next"])

    Process {
        id: proc

        command: [Env.hyprctl, "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const keyboards = JSON.parse(this.text).keyboards ?? [];
                    // The main keyboard is the one whose layout the switch
                    // moves; on a seat with several devices only it is right.
                    const main = keyboards.find(k => k.main) ?? keyboards[0];
                    root.layout = main?.active_keymap ?? "";
                } catch (e) {
                    root.layout = "";
                }
            }
        }
    }

    function refresh() {
        if (!proc.running)
            proc.running = true;
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.refresh();
        }
    }
}

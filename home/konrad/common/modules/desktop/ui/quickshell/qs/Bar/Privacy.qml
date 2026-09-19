pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Common
import qs.Config
import qs.Ui

// Microphone, camera and screen capture, each shown only while it is actually
// happening. All three are driven by events rather than polled: pipewire
// announces its own nodes, hyprland announces screencopy clients, and the
// camera watcher blocks on inotify.
Row {
    id: root

    // A node pipewire types as a stream reading from an audio source is an app
    // recording. Masking rather than comparing, because the type is a bitfield
    // and only these three bits say "capturing audio".
    readonly property var micStreams: Pipewire.nodes.values.filter(n => (n.type & PwNodeType.AudioInStream) === PwNodeType.AudioInStream)

    // Whoever is holding /dev/video*, already formatted by the watcher. Empty
    // means the camera is idle.
    property string cameraUsers: ""

    // Hyprland emits one screencast event per transition rather than a level,
    // so the number of clients is counted here. It is clamped because the shell
    // can start while something is already capturing and then see only the
    // closing event.
    property int castDepth: 0

    // What hyprland says is being copied: a monitor or a window. It is not the
    // client doing the copying -- that is not in the event.
    property string castTarget: ""

    readonly property bool casting: castDepth > 0
    property bool castingSettled: false

    // Node properties, and so the application name, are only filled in for
    // nodes something is holding open.
    PwObjectTracker {
        objects: root.micStreams
    }

    function appName(node) {
        return node.properties["application.name"] || node.description || node.name;
    }

    // The three read as one warning rather than as three more glyphs in the row.
    component Indicator: BarItem {
        background: Theme.urgent
        color: Theme.background
    }

    spacing: 4

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // v1 is what the count is built from, because it is the event every
            // hyprland emits; v2 rides along only to say what is being copied.
            if (event.name === "screencast") {
                // "<state>,<owner>"; state is 1 while a client is copying
                const starting = event.parse(2)[0] === "1";
                root.castDepth = Math.max(0, root.castDepth + (starting ? 1 : -1));
                if (root.castDepth === 0)
                    root.castTarget = "";
            } else if (event.name === "screencastv2") {
                // "<state>,<owner>,<name>", eg "1,monitor,eDP-1"
                const parts = event.parse(3);
                if (parts[0] === "1")
                    root.castTarget = parts[1] + " " + parts[2];
            }
        }
    }

    // A screenshot is a screencopy client like any other, so without this every
    // hyprshot would flash the indicator for a frame.
    Timer {
        id: settle

        interval: 500
        onTriggered: root.castingSettled = true
    }

    onCastingChanged: {
        if (root.casting)
            settle.restart();
        else {
            settle.stop();
            root.castingSettled = false;
        }
    }

    Process {
        id: cameraWatcher

        running: true
        command: Env.cameraWatch

        // A watcher that has died knows nothing, and leaving its last answer
        // standing would pin the indicator on for good.
        onRunningChanged: if (!cameraWatcher.running)
            root.cameraUsers = ""

        stdout: SplitParser {
            onRead: data => root.cameraUsers = data.trim()
        }
    }

    Indicator {
        active: root.micStreams.length > 0
        text: ""
        tooltip: "Microphone in use\n" + root.micStreams.map(n => root.appName(n)).join("\n")
    }

    Indicator {
        active: root.cameraUsers !== ""
        text: " "
        tooltip: "Camera in use\n" + root.cameraUsers
    }

    Indicator {
        active: root.castingSettled
        text: "󰍺 "
        tooltip: {
            const who = root.castDepth > 1 ? "Screen is being captured (" + root.castDepth + " clients)" : "Screen is being captured";
            return root.castTarget !== "" ? who + "\n" + root.castTarget : who;
        }
    }
}

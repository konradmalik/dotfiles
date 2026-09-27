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

    // One hyprland screencast session reports 1 when it starts and 0 when it
    // stops, so concurrent sharers are counted. Clamped, because the shell can
    // start while something is already capturing and see only the closing 0.
    property int castDepth: 0

    // What hyprland says is being copied: a monitor or a window. It is not the
    // client doing the copying -- that is not in the event.
    property string castTarget: ""

    spacing: 4
    // Nothing being captured means no widget at all, so the bar row does not
    // keep a gap for it.
    visible: implicitWidth > 0

    function appName(node) {
        return node.properties["application.name"] || node.description || node.name;
    }

    // The camera and screencast signals both drop out while the thing they
    // describe is still going: hyprland reports frames rather than sessions and
    // gives up 500ms after the last one, so sharing a screen that nobody is
    // touching flaps, and a camera app opens and closes the device several
    // times while it works out what it wants. Holding each on past its last
    // sighting turns that into one steady indicator. The microphone needs no
    // such thing -- a pipewire capture node is simply there or not.
    component Hold: Timer {
        required property bool input

        readonly property bool output: input || running

        interval: 2000

        onInputChanged: {
            if (input)
                stop();
            else
                restart();
        }
    }

    // The three read as one warning rather than as three more glyphs in the row.
    component Indicator: BarItem {
        background: Theme.urgent
        color: Theme.background
    }

    // Node properties, and so the application name, are only filled in for
    // nodes something is holding open.
    PwObjectTracker {
        objects: root.micStreams
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // v1 carries the state and v2 the same state plus what is being
            // copied, and both are emitted together, so only one may be counted.
            if (event.name === "screencast") {
                // "<state>,<owner>"; state is 1 while a client is copying
                const starting = event.parse(2)[0] === "1";
                root.castDepth = Math.max(0, root.castDepth + (starting ? 1 : -1));
            } else if (event.name === "screencastv2") {
                // "<state>,<owner>,<name>", eg "1,monitor,eDP-1"
                const parts = event.parse(3);
                if (parts[0] === "1")
                    root.castTarget = parts[1] + " " + parts[2];
            }
        }
    }

    Hold {
        id: cameraHold

        input: root.cameraUsers !== ""
    }

    // Longer than the camera's, because a shared screen can sit untouched for
    // seconds and hyprland will call that "not shared". Missing a live share
    // matters more than an icon that lingers after a one-off grab.
    Hold {
        id: castHold

        interval: 5000
        input: root.castDepth > 0
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
        active: cameraHold.output
        text: " "
        tooltip: "Camera in use\n" + root.cameraUsers
    }

    Indicator {
        active: castHold.output
        text: "󰍺 "
        tooltip: {
            const who = root.castDepth > 1 ? "Screen is being captured (" + root.castDepth + " clients)" : "Screen is being captured";
            return root.castTarget !== "" ? who + "\n" + root.castTarget : who;
        }
    }
}

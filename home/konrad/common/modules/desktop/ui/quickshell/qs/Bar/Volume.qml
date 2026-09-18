import QtQuick
import Quickshell.Services.Pipewire
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    readonly property list<string> icons: ["", "", ""]

    function setVolume(value) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    text: muted ? "" : icons[Math.min(icons.length - 1, Math.floor(volume * icons.length))]
    tooltip: {
        const out = sink?.description ?? sink?.name ?? "none";
        const inp = source?.description ?? source?.name ?? "none";
        const mic = source?.audio?.muted ? "muted" : Math.round((source?.audio?.volume ?? 0) * 100) + "%";
        return "Output: " + out + "\nInput: " + inp + "\n" + Math.round(volume * 100) + "%  mic " + mic;
    }

    onLeftClicked: Cmd.term(Env.mixer)
    onRightClicked: if (sink?.audio)
        sink.audio.muted = !sink.audio.muted
    onScrolledUp: root.setVolume(root.volume + 0.05)
    onScrolledDown: root.setVolume(root.volume - 0.05)

    // Pipewire only keeps volume and mute live for nodes something is holding
    // open, so the two defaults have to be bound explicitly.
    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}

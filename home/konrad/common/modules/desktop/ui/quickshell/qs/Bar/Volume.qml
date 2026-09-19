pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
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

    // Every real device, for the tooltip: the mask keeps duplex nodes, which are
    // both a sink and a source, and !isStream drops the per-application streams.
    readonly property var sinks: root.devices(PwNodeType.AudioSink)
    readonly property var sources: root.devices(PwNodeType.AudioSource)

    // Sorted by name, because pipewire hands devices over in whatever order it
    // learned about them and the list would otherwise shuffle under the cursor.
    function devices(mask) {
        return Pipewire.nodes.values.filter(n => !n.isStream && (n.type & mask) === mask).sort((a, b) => root.nameOf(a).localeCompare(root.nameOf(b)));
    }

    function nameOf(node) {
        return node ? node.nickname || node.description || node.name : "none";
    }

    function volumeOf(node) {
        if (!node?.audio)
            return "?";
        return node.audio.muted ? "muted" : Math.round(node.audio.volume * 100) + "%";
    }

    // One tooltip section: a heading, then every device on its own line with its
    // own level, rather than the names and the numbers in two separate places.
    function deviceLines(title, list, current) {
        return [title].concat(list.map(n => (n === current ? "* " : "  ") + root.nameOf(n) + "  " + root.volumeOf(n)));
    }

    function setVolume(value) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    text: muted ? "" : icons[Math.min(icons.length - 1, Math.floor(volume * icons.length))]
    tooltip: root.deviceLines("Output", root.sinks, root.sink).concat(root.deviceLines("Input", root.sources, root.source)).join("\n")

    onLeftClicked: root.popupOpen = !root.popupOpen
    onRightClicked: if (sink?.audio)
        sink.audio.muted = !sink.audio.muted
    onScrolledUp: root.setVolume(root.volume + 0.05)
    onScrolledDown: root.setVolume(root.volume - 0.05)

    // Pipewire only keeps volume and mute live for nodes something is holding
    // open, so every device the tooltip reports a level for has to be bound,
    // not just the two defaults.
    PwObjectTracker {
        objects: root.sinks.concat(root.sources)
    }

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: 180
                spacing: Theme.popupPadding

                Text {
                    width: parent.width
                    text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                    color: root.muted ? Theme.muted : Theme.text
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize
                }

                Slider {
                    width: parent.width
                    value: root.volume
                    fill: root.muted ? Theme.muted : Theme.accent

                    onMoved: value => root.setVolume(value)
                }

                Rectangle {
                    width: parent.width
                    height: Math.round(Theme.popupFontSize * 2.4)
                    radius: Theme.popupRadius
                    color: mixerMouse.containsMouse ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "Mixer"
                        textFormat: Text.PlainText
                        color: Theme.text
                        font.family: Theme.popupFontFamily
                        font.pointSize: Theme.popupFontSize
                    }

                    MouseArea {
                        id: mixerMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            root.popupOpen = false;
                            Cmd.term(Env.mixer);
                        }
                    }
                }
            }
        }
    }
}

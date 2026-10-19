pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs.Common

PanelWindow {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property string kind: "sink"
    property bool shown: false

    readonly property var node: kind === "sink" ? sink : kind === "source" ? source : null
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real level: node ? node.audio?.volume ?? 0 : Brightness.level
    readonly property string icon: {
        if (kind === "sink")
            return muted ? Theme.mutedIcon : Theme.glyph(Theme.volumeIcons, level);
        if (kind === "source")
            return muted ? Theme.micMutedIcon : Theme.micIcon;
        return Theme.glyph(Theme.brightnessIcons, level);
    }

    function show(kind) {
        root.kind = kind;
        root.shown = true;
        hide.restart();
    }

    // Binding a node fills in its volume and mute before it reports ready, which
    // would otherwise pop the OSD every time the shell starts.
    function showNode(kind, node) {
        if (node?.ready)
            root.show(kind);
    }

    screen: Shell.focusedScreen
    visible: shown || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Theme.osdWidth
    implicitHeight: card.implicitHeight
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"

    mask: Region {}

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    Timer {
        id: hide

        interval: Theme.osdTimeout
        onTriggered: root.shown = false
    }

    Connections {
        target: root.sink?.audio ?? null

        function onVolumeChanged() {
            root.showNode("sink", root.sink);
        }

        function onMutedChanged() {
            root.showNode("sink", root.sink);
        }
    }

    Connections {
        target: root.source?.audio ?? null

        function onVolumeChanged() {
            root.showNode("source", root.source);
        }

        function onMutedChanged() {
            root.showNode("source", root.source);
        }
    }

    Connections {
        target: Brightness

        function onLevelChanged() {
            if (Brightness.known)
                root.show("brightness");
        }
    }

    Rectangle {
        id: card

        width: parent.width
        implicitHeight: row.implicitHeight + Theme.osdPadding * 2
        radius: Theme.popupRadius
        color: Theme.background
        border.width: Theme.notificationBorder
        border.color: Theme.border
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: Theme.osdPadding

            Text {
                id: glyph

                anchors.verticalCenter: parent.verticalCenter
                width: Theme.fontSize * 4
                text: root.icon
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignHCenter
                color: root.muted ? Theme.muted : Theme.text
                font.family: Theme.fontFamily
                font.pointSize: Theme.popupFontSize * 3
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: card.width - Theme.osdPadding * 4 - glyph.width - percent.width
                height: 12
                radius: height / 2
                color: Theme.low

                Rectangle {
                    width: parent.width * Math.min(1, root.level)
                    height: parent.height
                    radius: parent.radius
                    color: root.muted ? Theme.muted : Theme.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: 80
                        }
                    }
                }
            }

            Text {
                id: percent

                anchors.verticalCenter: parent.verticalCenter
                width: Theme.popupFontSize * 5
                text: Math.round(root.level * 100) + "%"
                textFormat: Text.PlainText
                horizontalAlignment: Text.AlignRight
                color: root.muted ? Theme.muted : Theme.text
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize * 2
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    property real level: 0

    // brightnessctl is a process per change, which a drag would spawn faster
    // than they exit, so a change made while one is in flight is parked here
    // and the last one to arrive wins.
    property real pending: -1

    readonly property list<string> icons: ["", "", "", "", "", "", "", "", ""]

    // Zero is a screen that cannot be read back, and the slider makes it one
    // drag away, so the bottom of the range is a dim screen rather than a dark
    // one. The hyprland keybinds still go straight to brightnessctl.
    function set(value) {
        root.level = Math.max(0.01, Math.min(1, value));
        root.pending = root.level;
        if (!apply.running)
            root.flush();
    }

    function flush() {
        const value = root.pending;
        root.pending = -1;
        apply.command = [Env.brightnessctl, "set", Math.round(value * 100) + "%"];
        apply.running = true;
    }

    active: Env.hasBacklight
    text: icons[Math.min(icons.length - 1, Math.floor(level * icons.length))]
    tooltip: "Brightness " + Math.round(level * 100) + "%"

    onLeftClicked: root.popupOpen = !root.popupOpen
    onScrolledUp: root.set(root.level + 0.05)
    onScrolledDown: root.set(root.level - 0.05)

    Process {
        id: apply

        // Not onExited: its QProcess::ExitStatus parameter is not a type QML can
        // resolve, and running already goes false the moment the process ends.
        onRunningChanged: {
            if (apply.running)
                return;
            if (root.pending >= 0)
                root.flush();
            else
                poll.running = true;
        }
    }

    Process {
        id: poll

        // -m prints "device,class,current,percent%,max"; the percentage it
        // reports is already the perceptual one brightnessctl applies.
        command: [Env.brightnessctl, "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",");
                if (fields.length >= 4)
                    root.level = parseInt(fields[3]) / 100;
            }
        }
    }

    Timer {
        interval: 10000
        running: root.active
        repeat: true
        triggeredOnStart: true
        // A poll mid-drag would snap the slider back to whatever the last
        // applied step was, so it waits until the queue has drained.
        onTriggered: if (!poll.running && !apply.running && root.pending < 0)
            poll.running = true
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
                    text: Math.round(root.level * 100) + "%"
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.text
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize
                }

                Slider {
                    width: parent.width
                    value: root.level

                    onMoved: value => root.set(value)
                }
            }
        }
    }
}

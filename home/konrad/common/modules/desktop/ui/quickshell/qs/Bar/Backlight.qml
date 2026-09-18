import QtQuick
import Quickshell.Io
import qs.Config
import qs.Ui

BarItem {
    id: root

    property real level: 0

    readonly property list<string> icons: ["", "", "", "", "", "", "", "", ""]

    function step(direction) {
        set.command = [Env.brightnessctl, "set", direction > 0 ? "+5%" : "5%-"];
        set.running = true;
    }

    active: Env.hasBacklight
    text: icons[Math.min(icons.length - 1, Math.floor(level * icons.length))]
    tooltip: "Brightness " + Math.round(level * 100) + "%"

    onScrolledUp: root.step(1)
    onScrolledDown: root.step(-1)

    Process {
        id: set

        onExited: poll.running = true
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
        onTriggered: if (!poll.running)
            poll.running = true
    }
}

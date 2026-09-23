pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    property string backendState: "NoState"
    property string host: "?"
    property string address: "no address"

    readonly property color dotColor: {
        if (backendState === "Running")
            return Theme.text;
        if (backendState === "NeedsLogin")
            return Theme.warning;
        return Theme.muted;
    }

    active: Env.hasTailscale
    tooltip: "Tailscale: " + backendState + "\n" + host + " (" + address + ")"

    onLeftClicked: Cmd.run(Env.tailscaleToggle)
    onRightClicked: Cmd.run(Env.tailscaleCopyIp)

    // The nine-dot mark, four of them solid drawing the "t": the middle row and
    // the dot below it, as in the official logo. No font carries it, so it is
    // drawn rather than set as a glyph.
    Grid {
        anchors.verticalCenter: parent.verticalCenter
        columns: 3
        spacing: Math.round(Theme.fontSize * 0.16)

        Repeater {
            model: 9

            Rectangle {
                required property int index

                readonly property bool solid: [3, 4, 5, 7].includes(index)

                width: Math.round(Theme.fontSize * 0.4)
                height: width
                radius: width / 2
                color: root.dotColor
                opacity: solid ? 1 : 0.35
            }
        }
    }

    Process {
        id: poll

        // Reading the status needs no operator bit; tailscaled hands every local
        // user read-only access. The cli exits non-zero in some states while
        // still printing usable json, so only the json is trusted.
        command: [Env.tailscale, "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                const status = Cmd.json(this.text, {});
                root.backendState = status.BackendState ?? "NoState";
                root.host = status.Self?.HostName ?? "?";
                root.address = status.TailscaleIPs?.[0] ?? "no address";
            }
        }
    }

    // The ipn bus is read for its noise alone: a line off it only means
    // "something moved, ask again", so the pretty-printed notification never
    // has to be parsed. --initial makes every connection say it once, which is
    // both the first read and what makes a reconnect catch up on whatever
    // changed while the watch was gone.
    Process {
        id: watch

        running: root.active
        command: [Env.tailscale, "debug", "watch-ipn", "--initial"]
        stdout: SplitParser {
            onRead: settle.restart()
        }
    }

    // One transition arrives as a burst of notifications, and the status is
    // worth reading once it has landed rather than once per line.
    Timer {
        id: settle

        interval: 200
        onTriggered: poll.running = true
    }

    // tailscaled going away takes the watch with it, and it is the only thing
    // keeping this off a timer.
    Timer {
        id: reconnect

        interval: 5000
        running: root.active && !watch.running
        onTriggered: watch.running = true
    }
}

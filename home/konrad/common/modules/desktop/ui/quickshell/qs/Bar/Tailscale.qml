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

    onLeftClicked: {
        Cmd.run(Env.tailscaleToggle);
        poller.burst = 3;
        poller.restart();
    }
    onRightClicked: Cmd.run(Env.tailscaleCopyIp)

    // The nine-dot mark, five of them solid drawing the "t". No font carries
    // it, so it is drawn rather than set as a glyph.
    Grid {
        anchors.verticalCenter: parent.verticalCenter
        columns: 3
        spacing: Math.round(Theme.fontSize * 0.16)

        Repeater {
            model: 9

            Rectangle {
                required property int index

                readonly property bool solid: [0, 1, 2, 4, 7].includes(index)

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

    Timer {
        id: poller

        // A toggle takes a moment to settle, so a click buys a few quick reads
        // before the idle beat resumes.
        property int burst: 0

        interval: burst > 0 ? 1500 : 10000
        running: root.active
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!poll.running)
                poll.running = true;
            if (burst > 0)
                burst--;
        }
    }
}

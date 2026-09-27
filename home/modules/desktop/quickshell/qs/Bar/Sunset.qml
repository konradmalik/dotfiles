import QtQuick
import Quickshell.Io
import qs.Config
import qs.Ui

BarItem {
    id: root

    property string unitState: "inactive"
    property string filterState: "unknown"

    readonly property var icons: ({
            inactive: "󰱥",
            filtered: "󰖔",
            identity: "󰖙",
            active: "󰔎",
            failed: "󰀦"
        })

    readonly property string status: unitState === "active" && filterState !== "unknown" ? filterState : unitState

    text: icons[status] ?? icons.failed
    tooltip: {
        switch (status) {
        case "filtered":
            return "blue light filter on";
        case "identity":
            return "blue light filter off (hyprsunset idle)";
        default:
            return "hyprsunset is " + unitState;
        }
    }

    onLeftClicked: {
        toggle.command = [Env.systemctl, "--user", root.unitState === "active" ? "stop" : "start", "hyprsunset"];
        toggle.running = true;
    }

    Process {
        id: toggle

        // Not onExited: its QProcess::ExitStatus parameter is not a type QML can
        // resolve, and running already goes false the moment the process ends.
        onRunningChanged: if (!toggle.running)
            poll.running = true
    }

    Process {
        id: poll

        // systemctl exits non-zero for every state but active, so the status
        // has to be read off stdout rather than the exit code.
        command: [Env.systemctl, "--user", "is-active", "hyprsunset"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.unitState = this.text.trim() || "unknown";
                if (root.unitState !== "active")
                    root.filterState = "unknown";
                else if (!filter.running)
                    filter.running = true;
            }
        }
    }

    Process {
        id: filter

        command: [Env.hyprctl, "hyprsunset", "identity", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                const reply = this.text.trim();
                root.filterState = reply === "false" ? "filtered" : reply === "true" ? "identity" : "unknown";
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!poll.running)
            poll.running = true
    }
}

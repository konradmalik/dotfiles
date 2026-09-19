import QtQuick
import Quickshell.Io
import qs.Config
import qs.Ui

BarItem {
    id: root

    property string unitState: "inactive"

    readonly property var icons: ({
            inactive: "󱓤",
            active: "󱁞",
            failed: "",
            activating: "",
            deactivating: "",
            maintenance: "󱤴",
            reloading: "󰑓",
            refreshing: "󰑓"
        })

    text: icons[unitState] ?? icons.inactive
    tooltip: "hyprsunset is " + unitState

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
            onStreamFinished: root.unitState = this.text.trim() || "inactive"
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!poll.running)
            poll.running = true
    }
}

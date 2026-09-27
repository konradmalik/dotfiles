import QtQuick
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    text: ""
    color: Sys.cpuUsage >= 0.9 ? Theme.urgent : Sys.cpuUsage >= 0.7 ? Theme.warning : Theme.text
    tooltip: "CPU " + Math.round(Sys.cpuUsage * 100) + "%"

    onLeftClicked: Cmd.term(Env.systemMonitor)
}

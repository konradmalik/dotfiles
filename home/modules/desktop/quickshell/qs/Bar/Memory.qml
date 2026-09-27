import QtQuick
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    text: ""
    color: Sys.memUsage >= 0.9 ? Theme.urgent : Sys.memUsage >= 0.7 ? Theme.warning : Theme.text
    tooltip: "RAM " + Sys.memUsed.toFixed(1) + "/" + Sys.memTotal.toFixed(1) + " GiB (" + Math.round(Sys.memUsage * 100) + "%)"

    onLeftClicked: Cmd.term(Env.systemMonitor)
}

import QtQuick
import Quickshell.Io
import qs.Common
import qs.Ui

BarItem {
    id: root

    property string uptime: ""

    function pretty(text) {
        const seconds = Number(text.split(/\s+/)[0]);
        if (!isFinite(seconds))
            return "";

        const units = [[Math.floor(seconds / 86400), "day"], [Math.floor(seconds % 86400 / 3600), "hour"], [Math.floor(seconds % 3600 / 60), "minute"]];
        const parts = units.filter(u => u[0] > 0).map(u => u[0] + " " + u[1] + (u[0] === 1 ? "" : "s"));
        return "up " + (parts.length > 0 ? parts.join(", ") : "0 minutes");
    }

    text: "\uf011"
    tooltip: uptime

    onLeftClicked: Shell.powerOpen = !Shell.powerOpen

    FileView {
        id: proc

        path: "/proc/uptime"
        onLoaded: root.uptime = root.pretty(text())
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.reload()
    }
}

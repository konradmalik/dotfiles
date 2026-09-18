pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property real memUsed: 0
    property real memTotal: 0

    readonly property real memUsage: memTotal > 0 ? memUsed / memTotal : 0

    // /proc/stat counts ticks since boot, so a percentage only exists as the
    // difference between two readings; the first one just seeds the baseline.
    property real lastBusy: -1
    property real lastTotal: -1

    function readCpu(text) {
        const fields = text.split("\n")[0].split(/\s+/).slice(1).map(Number);
        const total = fields.reduce((a, b) => a + b, 0);
        const idle = fields[3] + (fields[4] || 0);
        const busy = total - idle;

        if (root.lastTotal >= 0 && total > root.lastTotal)
            root.cpuUsage = (busy - root.lastBusy) / (total - root.lastTotal);

        root.lastBusy = busy;
        root.lastTotal = total;
    }

    function readMemory(text) {
        const kib = key => {
            const line = text.split("\n").find(l => l.startsWith(key));
            return line ? Number(line.split(/\s+/)[1]) / 1048576 : 0;
        };

        root.memTotal = kib("MemTotal:");
        root.memUsed = root.memTotal - kib("MemAvailable:");
    }

    property FileView stat: FileView {
        path: "/proc/stat"
        onLoaded: root.readCpu(text())
    }

    property FileView meminfo: FileView {
        path: "/proc/meminfo"
        onLoaded: root.readMemory(text())
    }

    property Timer timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.stat.reload();
            root.meminfo.reload();
        }
    }
}

import QtQuick
import Quickshell
import qs.Ui

BarItem {
    id: root

    property int monthOffset: 0

    readonly property date now: clock.date

    function calendar(when, offset) {
        const shown = new Date(when.getFullYear(), when.getMonth() + offset, 1);
        const year = shown.getFullYear();
        const month = shown.getMonth();
        const days = new Date(year, month + 1, 0).getDate();
        // Monday-first, so Sunday (0) belongs at the end of the previous row.
        const lead = (shown.getDay() + 6) % 7;

        let out = Qt.formatDate(shown, "MMMM yyyy") + "\nMo Tu We Th Fr Sa Su\n";
        let cells = [];
        for (let i = 0; i < lead; i++)
            cells.push("  ");
        for (let d = 1; d <= days; d++) {
            const today = offset === 0 && d === when.getDate();
            cells.push((today ? "*" : " ") + (d < 10 ? " " + d : String(d)));
        }

        for (let i = 0; i < cells.length; i += 7)
            out += cells.slice(i, i + 7).join(" ").replace(/\s+$/, "") + "\n";

        return out.replace(/\n$/, "");
    }

    bold: true
    text: Qt.formatDateTime(now, "yyyy-MM-dd HH:mm")
    tooltip: calendar(now, monthOffset)

    onScrolledUp: root.monthOffset -= 1
    onScrolledDown: root.monthOffset += 1
    onRightClicked: root.monthOffset = 0

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}

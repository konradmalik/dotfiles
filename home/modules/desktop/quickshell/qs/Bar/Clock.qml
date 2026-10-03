pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Ui
import "Clock"

// The clock, with the month behind a click. The calendar itself lives in
// Clock/.
BarItem {
    id: root

    property int monthOffset: 0

    readonly property date now: clock.date
    readonly property date shown: new Date(now.getFullYear(), now.getMonth() + monthOffset, 1)

    // Qt formats in local time and cannot be told otherwise -- formatDateTime's
    // third argument picks a locale's format type, not a zone. The same instant
    // shifted by the offset reads, in local time, as UTC does, so it can go
    // through the same formatter, weekday and month names included.
    readonly property date nowUtc: new Date(now.getTime() + now.getTimezoneOffset() * 60000)

    bold: true
    text: Qt.formatDateTime(now, "yyyy-MM-dd HH:mm")
    // Here, then UTC under it, both spelled out in full: the two are not always
    // on the same date, which is why the second entry carries a date of its own
    // rather than a bare time.
    tooltip: [Qt.formatDateTime(root.now, "dddd, d MMMM yyyy, HH:mm t"), Qt.formatDateTime(nowUtc, "dddd, d MMMM yyyy, HH:mm") + " UTC"].join("\n")

    onLeftClicked: root.popupOpen = !root.popupOpen
    onRightClicked: root.monthOffset = 0
    onScrolledUp: root.monthOffset -= 1
    onScrolledDown: root.monthOffset += 1

    // On open, not on close: the wheel keeps working over a shut popup, so
    // resetting on the way out still let a stray scroll decide which month the
    // next open landed on.
    onPopupOpenChanged: if (root.popupOpen)
        root.monthOffset = 0

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Calendar {
                shown: root.shown

                onStepped: step => root.monthOffset += step
            }
        }
    }
}

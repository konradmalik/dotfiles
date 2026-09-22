pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Common
import qs.Ui

// The clock, with the month behind a click. The grid is QtQuick.Controls':
// laying weeks out by hand means getting the lead-in, the month length and the
// locale's first day right, and then keeping the weekday header lined up with
// the columns under it -- which is exactly what the hand-rolled one got wrong.
// MonthGrid and DayOfWeekRow share a column count and a spacing, so giving both
// delegates the same cell width lines them up by construction.
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

    component Stepper: Text {
        id: stepper

        required property int step

        color: mouse.containsMouse ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.pointSize: Theme.popupFontSize

        // A chevron is a small target, so the area it answers to is larger.
        MouseArea {
            id: mouse

            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true

            onClicked: root.monthOffset += stepper.step
        }
    }

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: Theme.popupWidth
                spacing: 4

                Item {
                    width: parent.width
                    height: Theme.popupRowHeight

                    Stepper {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        step: -1
                        text: "󰅁"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: grid.locale.standaloneMonthName(grid.month) + " " + grid.year
                        textFormat: Text.PlainText
                        color: Theme.text
                        font.family: Theme.popupFontFamily
                        font.pointSize: Theme.popupFontSize
                        font.weight: Theme.emphasisWeight
                    }

                    Stepper {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        step: 1
                        text: "󰅂"
                    }
                }

                DayOfWeekRow {
                    width: parent.width
                    padding: 0
                    spacing: grid.spacing
                    locale: grid.locale

                    delegate: Text {
                        required property string shortName

                        width: grid.cellWidth
                        horizontalAlignment: Text.AlignHCenter
                        text: shortName
                        textFormat: Text.PlainText
                        // Some locales spell the short name longer than the
                        // column; better clipped than bleeding into Monday.
                        elide: Text.ElideRight
                        color: Theme.muted
                        font.family: Theme.popupFontFamily
                        font.pointSize: Theme.popupLabelFontSize
                    }
                }

                MonthGrid {
                    id: grid

                    readonly property real cellWidth: (width - spacing * 6) / 7

                    width: parent.width
                    padding: 0
                    spacing: 4
                    // The locale names the days and decides which one the
                    // week starts on. The title is taken from this same one, so
                    // the header can never end up in another language than the
                    // month above it.
                    locale: Qt.locale()
                    month: root.shown.getMonth()
                    year: root.shown.getFullYear()

                    delegate: Text {
                        required property var model

                        width: grid.cellWidth
                        horizontalAlignment: Text.AlignHCenter
                        text: model.day
                        textFormat: Text.PlainText
                        // The days either side are there to square off the
                        // weeks; they are not this month's business.
                        color: model.today ? Theme.accent : model.month === grid.month ? Theme.text : Theme.low
                        font.family: Theme.popupFontFamily
                        font.pointSize: Theme.popupFontSize
                        font.weight: model.today ? Theme.emphasisWeight : Font.Normal
                    }
                }
            }
        }
    }
}

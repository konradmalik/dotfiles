pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property real level: Brightness.level

    active: Env.hasBacklight
    text: Theme.glyph(Theme.brightnessIcons, level)
    tooltip: "Brightness " + Math.round(level * 100) + "%"

    onLeftClicked: root.popupOpen = !root.popupOpen
    onScrolledUp: Brightness.set(root.level + 0.05)
    onScrolledDown: Brightness.set(root.level - 0.05)

    LazyLoader {
        active: root.popupOpen

        BarPopup {
            anchorItem: root
            visible: true

            onDismissed: root.popupOpen = false

            Column {
                width: Theme.popupWidth
                spacing: Theme.popupPadding

                Text {
                    width: parent.width
                    text: Math.round(root.level * 100) + "%"
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.text
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize
                }

                Slider {
                    width: parent.width
                    value: root.level

                    onMoved: value => Brightness.set(value)
                }
            }
        }
    }
}

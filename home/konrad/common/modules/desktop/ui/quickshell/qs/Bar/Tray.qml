import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Common
import qs.Ui

Row {
    id: root

    // An empty tray takes no space in the bar row, gap included.
    visible: implicitWidth > 0

    Repeater {
        model: SystemTray.items

        BarItem {
            id: item

            required property var modelData

            tooltip: modelData.tooltipTitle || modelData.title || modelData.id

            // Some items exist only to hold a menu and treat a left click as a
            // no-op, so the menu is what a left click opens for those.
            onLeftClicked: {
                if (modelData.onlyMenu)
                    menu.open();
                else
                    modelData.activate();
            }
            onRightClicked: menu.open()
            onMiddleClicked: modelData.secondaryActivate()

            IconImage {
                anchors.verticalCenter: parent.verticalCenter
                source: item.modelData.icon
                implicitSize: Math.round(Theme.fontSize * 1.6)
            }

            QsMenuAnchor {
                id: menu

                menu: item.modelData.menu
                anchor.item: item
                anchor.rect.y: item.height
                anchor.rect.width: item.width
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}

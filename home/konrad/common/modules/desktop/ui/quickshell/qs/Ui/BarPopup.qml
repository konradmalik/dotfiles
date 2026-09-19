import QtQuick
import Quickshell
import qs.Common

// The framed panel a BarItem drops when it is clicked. Like Tooltip it has to
// be a real wayland popup, because the bar is a layer surface only as tall as
// the bar itself and would clip anything drawn inside it.
PopupWindow {
    id: root

    default property alias content: body.data
    required property Item anchorItem

    anchor.item: anchorItem
    anchor.rect.y: anchorItem ? anchorItem.height : 0
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"

    Rectangle {
        id: frame

        implicitWidth: body.implicitWidth + Theme.popupPadding * 2
        implicitHeight: body.implicitHeight + Theme.popupPadding * 2
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        radius: Theme.popupRadius

        Item {
            id: body

            x: Theme.popupPadding
            y: Theme.popupPadding
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            width: implicitWidth
            height: implicitHeight
        }
    }
}

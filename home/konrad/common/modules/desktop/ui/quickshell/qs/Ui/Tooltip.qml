import QtQuick
import Quickshell
import qs.Common

// A real wayland popup rather than a Qt Quick Controls ToolTip: the bar is a
// layer surface only as tall as the bar, and an in-window popup would be
// clipped by it.
PopupWindow {
    id: root

    required property Item anchorItem
    required property string text

    anchor.item: anchorItem
    anchor.rect.y: anchorItem ? anchorItem.height : 0
    anchor.rect.width: anchorItem ? anchorItem.width : 0
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"

    Rectangle {
        id: frame

        implicitWidth: label.width + Theme.popupPadding * 2
        implicitHeight: label.height + Theme.popupPadding * 2
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        radius: Theme.popupRadius

        Text {
            id: label

            x: Theme.popupPadding
            y: Theme.popupPadding
            text: root.text
            textFormat: Text.PlainText
            color: Theme.text
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize
            // A long tooltip wraps at the cap; a short one must not be padded
            // out to it, so the width only binds once the cap is exceeded.
            width: Math.min(implicitWidth, Theme.tooltipMaxWidth)
            wrapMode: Text.WordWrap
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Common

// The framed panel a BarItem drops when it is clicked. Like Tooltip it has to
// be a real wayland popup, because the bar is a layer surface only as tall as
// the bar itself and would clip anything drawn inside it.
PopupWindow {
    id: root

    default property alias content: body.data
    required property Item anchorItem

    signal dismissed

    anchor.item: anchorItem
    // The anchor is the item's whole width rather than a point at its corner,
    // so the popup hangs centred under the thing that opened it instead of
    // starting at its left edge.
    anchor.rect.y: anchorItem.height
    anchor.rect.width: anchorItem.width
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"

    // Clicking anywhere else closes the popup. The bar is whitelisted next to
    // the popup itself, so a click on the item that opened this still reaches
    // it and toggles the popup shut, rather than being swallowed as the click
    // that clears the grab -- the protocol leaves that delivery to the
    // compositor. It also means one popup replaces another: starting a second
    // grab clears the first.
    HyprlandFocusGrab {
        windows: root.parentWindow ? [root, root.parentWindow] : [root]
        active: root.visible
        onCleared: root.dismissed()
    }

    Rectangle {
        id: frame

        implicitWidth: body.implicitWidth + Theme.popupPadding * 2
        implicitHeight: body.implicitHeight + Theme.popupPadding * 2
        color: Theme.background
        border.width: 1
        border.color: Theme.border
        radius: Theme.popupRadius

        // Content has to carry its own width: this tracks childrenRect, so a
        // child sizing itself to the parent would be a loop.
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

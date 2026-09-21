import QtQuick
import qs.Common

// The frame every clickable line in a popup wears: as wide as the popup, one
// row high, lit while the pointer is on it. The border is what separates it
// from what is around it, so a row hanging off something that already has one
// turns it off.
//
// Needs a width, either from a parent that has one or set directly -- a popup
// that sizes itself to its contents cannot supply it.
Rectangle {
    id: root

    default property alias content: body.data

    property bool bordered: true

    signal clicked

    width: parent.width
    implicitHeight: Theme.popupRowHeight
    radius: Theme.popupRadius
    color: mouse.containsMouse ? Theme.hover : "transparent"
    border.width: bordered ? 1 : 0
    border.color: Theme.border

    Item {
        id: body

        anchors.fill: parent
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.clicked()
    }
}

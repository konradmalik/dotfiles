import QtQuick
import qs.Common

// One on/off row for a popup. The box is a glyph rather than a drawn square,
// so it sits on the same baseline as every other icon in the shell.
//
// Needs a width, either from a parent that has one or set directly -- a popup
// that sizes itself to its contents cannot supply it.
Rectangle {
    id: root

    required property string label
    property bool checked: false

    signal toggled(bool checked)

    width: parent.width
    implicitHeight: Math.round(Theme.popupFontSize * 2.4)
    radius: Theme.popupRadius
    color: mouse.containsMouse ? Theme.hover : "transparent"
    border.width: 1
    border.color: Theme.border

    Text {
        id: box

        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.checked ? "󰄵" : "󰄱"
        color: root.checked ? Theme.accent : Theme.muted
        font.family: Theme.fontFamily
        font.pointSize: Theme.popupFontSize
    }

    // Glyphs come out of the monospace nerd font, labels out of the popup font,
    // so they cannot share a Text.
    Text {
        anchors.left: box.right
        anchors.leftMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: Theme.text
        font.family: Theme.popupFontFamily
        font.pointSize: Theme.popupFontSize
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.toggled(!root.checked)
    }
}

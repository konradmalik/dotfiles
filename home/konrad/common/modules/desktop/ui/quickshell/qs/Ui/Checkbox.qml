import QtQuick
import qs.Common

// One on/off row for a popup. The box is a glyph rather than a drawn square,
// so it sits on the same baseline as every other icon in the shell.
PopupRow {
    id: root

    required property string label
    property bool checked: false

    signal toggled(bool checked)

    onClicked: root.toggled(!root.checked)

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
}

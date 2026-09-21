pragma ComponentBehavior: Bound
import QtQuick
import qs.Common

// A folding list of choices: a header carrying the current one, and the rest
// revealed underneath when it is clicked. Options are plain objects, `value`
// and `label`, optionally `icon` for a glyph in front of the label.
//
// Needs a width, either from a parent that has one or set directly -- a popup
// that sizes itself to its contents cannot supply it.
Column {
    id: root

    required property string title
    required property var options
    required property var current

    property bool expanded: false

    signal picked(var value)

    function labelOf(value) {
        const found = root.options.find(o => o.value === value);
        return found ? found.label : "none";
    }

    width: parent.width
    spacing: 2

    PopupRow {
        onClicked: root.expanded = !root.expanded

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: chevron.left
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: root.title + ": " + root.labelOf(root.current)
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: Theme.text
            font.family: Theme.popupFontFamily
            font.pointSize: Theme.popupFontSize
        }

        Text {
            id: chevron

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            text: root.expanded ? "󰅃" : "󰅀"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pointSize: Theme.popupFontSize
        }
    }

    Repeater {
        model: root.expanded ? root.options : []

        // The rows read as a list hanging off the header, so they carry no
        // border of their own.
        PopupRow {
            id: row

            required property var modelData

            readonly property bool isCurrent: modelData.value === root.current

            bordered: false

            // Collapse first: whoever is listening may well close whatever this
            // is sitting in, and then there is nothing left to set.
            onClicked: {
                root.expanded = false;
                root.picked(row.modelData.value);
            }

            // Glyphs come out of the monospace nerd font, labels out of the
            // popup font, so they cannot share a Text.
            Text {
                id: glyph

                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
                text: row.modelData.icon ?? ""
                color: row.isCurrent ? Theme.accent : Theme.text
                font.family: Theme.fontFamily
                font.pointSize: Theme.popupFontSize
            }

            Text {
                anchors.left: glyph.visible ? glyph.right : parent.left
                anchors.leftMargin: glyph.visible ? 6 : 8
                anchors.right: mark.left
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: row.isCurrent ? Theme.accent : Theme.text
                font.family: Theme.popupFontFamily
                font.pointSize: Theme.popupFontSize
            }

            Text {
                id: mark

                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                visible: row.isCurrent
                text: "󰄬"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pointSize: Theme.popupFontSize
            }
        }
    }
}

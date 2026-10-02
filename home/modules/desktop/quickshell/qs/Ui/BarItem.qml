pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Common

Item {
    id: root

    default property alias content: row.data

    property string text: ""
    property string tooltip: ""
    property color color: Theme.text
    // Filled behind the item, for states that have to read as a warning rather
    // than as one more glyph in the row.
    property color background: "transparent"
    property int padding: Theme.itemPadding
    property int spacing: 4
    property bool bold: false
    property bool active: true

    // Set by items that drop a BarPopup: a tooltip must not stack on top of the
    // panel the same click just opened.
    property bool popupOpen: false

    readonly property bool hovered: mouse.containsMouse
    readonly property bool tooltipArmed: hovered && tooltip !== "" && !popupOpen

    signal leftClicked
    signal rightClicked
    signal middleClicked
    signal scrolledUp
    signal scrolledDown

    implicitWidth: active && row.implicitWidth > 0 ? row.implicitWidth + padding * 2 : 0
    implicitHeight: Theme.barHeight
    visible: implicitWidth > 0

    component Highlight: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Theme.highlightHeight
        radius: Theme.radius
    }

    Highlight {
        visible: root.background.a > 0
        color: root.background
    }

    Highlight {
        color: Theme.hover
        opacity: mouse.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.spacing

        Text {
            id: label

            // Text narrower than its height gets a square slot with its ink centred in it.
            //
            // Everything here is measured from the ink and the line height;
            // measuring from width (which follows implicitWidth, and includes leftPadding) is a binding loop.
            readonly property bool square: ink.tightBoundingRect.width < height

            anchors.verticalCenter: parent.verticalCenter
            width: square ? height : implicitWidth
            leftPadding: square ? Math.round((height - ink.tightBoundingRect.width) / 2 - ink.tightBoundingRect.x) : 0
            visible: root.text !== ""
            text: root.text
            textFormat: Text.PlainText
            color: root.color
            font.family: Theme.fontFamily
            font.pointSize: Theme.fontSize
            font.bold: root.bold

            TextMetrics {
                id: ink

                font: label.font
                text: root.text
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: event => {
            if (event.button === Qt.LeftButton)
                root.leftClicked();
            else if (event.button === Qt.RightButton)
                root.rightClicked();
            else if (event.button === Qt.MiddleButton)
                root.middleClicked();
        }

        // A wheel reports 120-unit steps and a touchpad reports pixels, so only
        // the sign of the delta is meaningful across both.
        onWheel: event => {
            const dy = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y;
            if (dy > 0)
                root.scrolledUp();
            else if (dy < 0)
                root.scrolledDown();
        }
    }

    Timer {
        id: hoverDelay

        interval: 400
        onTriggered: tooltipLoader.active = true
    }

    onTooltipArmedChanged: {
        if (root.tooltipArmed)
            hoverDelay.restart();
        else {
            hoverDelay.stop();
            tooltipLoader.active = false;
        }
    }

    LazyLoader {
        id: tooltipLoader

        active: false

        Tooltip {
            anchorItem: root
            text: root.tooltip
            visible: true
        }
    }
}

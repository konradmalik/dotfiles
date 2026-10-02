pragma ComponentBehavior: Bound
import QtQuick
import qs.Common

// Three bars bouncing out of step: the "this one is making sound" sign next to
// a playing player's name. It only animates while it is shown.
Row {
    id: root

    height: 10
    spacing: 2

    Repeater {
        // A different period per bar, so they never settle into lockstep.
        model: [320, 450, 380]

        Rectangle {
            id: bar

            required property int modelData

            anchors.bottom: root.bottom
            width: 3
            color: Theme.accent

            SequentialAnimation on height {
                running: root.visible
                loops: Animation.Infinite

                NumberAnimation {
                    to: root.height
                    duration: bar.modelData
                }
                NumberAnimation {
                    to: 2
                    duration: bar.modelData
                }
            }
        }
    }
}

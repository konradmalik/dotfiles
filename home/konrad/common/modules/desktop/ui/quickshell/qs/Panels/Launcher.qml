pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Ui

Overlay {
    id: root

    property string query: ""
    property int selected: 0

    readonly property int rowHeight: Math.round(Theme.popupFontSize * 3)
    readonly property int maxRows: 8

    readonly property var results: {
        const needle = root.query.trim().toLowerCase();

        // A prefix match on the name is what someone typing three letters means;
        // everything else ranks behind it, and -1 drops out entirely.
        const rank = entry => {
            if (needle === "")
                return 0;

            const at = entry.name.toLowerCase().indexOf(needle);
            if (at >= 0)
                return at === 0 ? 0 : 1;

            const haystack = [entry.genericName, entry.comment, (entry.keywords ?? []).join(" ")].join(" ").toLowerCase();
            return haystack.indexOf(needle) >= 0 ? 2 : -1;
        };

        return DesktopEntries.applications.values.filter(entry => !entry.noDisplay).map(entry => ({
                    entry,
                    rank: rank(entry)
                })).filter(scored => scored.rank >= 0).sort((a, b) => a.rank - b.rank || a.entry.name.localeCompare(b.entry.name)).slice(0, 50).map(scored => scored.entry);
    }

    function launch() {
        const entry = root.results[root.selected];
        if (entry)
            entry.execute();
        Shell.launcherOpen = false;
    }

    function move(delta) {
        if (root.results.length === 0)
            return;
        root.selected = Math.max(0, Math.min(root.results.length - 1, root.selected + delta));
    }

    shown: Shell.launcherOpen
    onDismissed: Shell.launcherOpen = false
    onShownChanged: {
        if (!shown)
            return;
        root.query = "";
        root.selected = 0;
        input.forceActiveFocus();
    }
    onQueryChanged: root.selected = 0

    // The overlay centres what it is given, so this reserves the height of a
    // full list and keeps it: a card that shrank with the results would drag
    // the search box down the screen as you typed.
    Item {
        implicitWidth: 620
        implicitHeight: search.height + root.maxRows * root.rowHeight

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: search.height + list.height
            color: Theme.background
            border.width: 1
            border.color: Theme.border
            radius: Theme.popupRadius

            Item {
                id: search

                width: parent.width
                height: root.rowHeight + 8

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.query
                    color: Theme.text
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.background
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize + 2
                    clip: true
                    focus: true

                    onTextChanged: root.query = text

                    Keys.onDownPressed: root.move(1)
                    Keys.onUpPressed: root.move(-1)
                    Keys.onReturnPressed: root.launch()
                    Keys.onEnterPressed: root.launch()
                    Keys.onTabPressed: root.move(1)

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Search applications"
                        color: Theme.muted
                        font: input.font
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.border
                }
            }

            ListView {
                id: list

                y: search.height
                width: parent.width
                height: Math.min(root.results.length, root.maxRows) * root.rowHeight
                model: root.results
                currentIndex: root.selected
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0
                // Keeps the keyboard cursor on screen once the list is longer than
                // the eight rows the popup shows.
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width: list.width
                    height: root.rowHeight
                    color: index === root.selected ? Theme.hover : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(row.modelData.icon, true)
                            implicitSize: Math.round(root.rowHeight * 0.6)
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - parent.spacing - Math.round(root.rowHeight * 0.6)

                            Text {
                                width: parent.width
                                text: row.modelData.name
                                textFormat: Text.PlainText
                                color: Theme.text
                                font.family: Theme.popupFontFamily
                                font.pointSize: Theme.popupFontSize
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                visible: text !== ""
                                text: row.modelData.genericName ?? ""
                                textFormat: Text.PlainText
                                color: Theme.muted
                                font.family: Theme.popupFontFamily
                                font.pointSize: Theme.popupLabelFontSize
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = row.index
                        onClicked: {
                            root.selected = row.index;
                            root.launch();
                        }
                    }
                }
            }
        }
    }
}

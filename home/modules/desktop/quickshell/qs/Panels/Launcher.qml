pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Ui

Overlay {
    id: root

    readonly property alias query: input.text
    property int selected: 0

    readonly property int cardWidth: 620
    readonly property int cardPadding: 16
    readonly property int rowHeight: Math.round(Theme.popupFontSize * 3)
    readonly property int iconSize: Math.round(rowHeight * 0.6)
    readonly property int searchHeight: rowHeight + 8
    readonly property int maxRows: 8
    // Nothing past this is reachable without typing more, and it keeps the
    // sort on every keystroke off the far end of a full application menu.
    readonly property int maxResults: 50

    // Split out because it only changes when something is installed or
    // removed, so the per-keystroke filter below does not redo it.
    readonly property var entries: DesktopEntries.applications.values.filter(entry => !entry.noDisplay)

    readonly property var results: {
        const needle = root.query.trim().toLowerCase();
        const scored = root.entries.map(entry => ({
                    entry,
                    rank: root.rank(entry, needle)
                })).filter(hit => hit.rank >= 0);
        scored.sort((a, b) => a.rank - b.rank || a.entry.name.localeCompare(b.entry.name));
        return scored.slice(0, root.maxResults).map(hit => hit.entry);
    }

    // A prefix match on the name is what someone typing three letters means;
    // everything else ranks behind it, and -1 drops out entirely.
    function rank(entry, needle) {
        if (needle === "")
            return 0;

        const at = entry.name.toLowerCase().indexOf(needle);
        if (at >= 0)
            return at === 0 ? 0 : 1;

        const haystack = [entry.genericName, entry.comment, entry.keywords.join(" ")].join(" ").toLowerCase();
        return haystack.includes(needle) ? 2 : -1;
    }

    function launch() {
        const entry = root.results[root.selected];
        // Nothing matched, so there is nothing to launch and no reason to
        // close: the query is a typo the user still wants to correct.
        if (!entry)
            return;
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
        input.clear();
        root.selected = 0;
        input.forceActiveFocus();
    }
    // Any new result set -- a keystroke, or an application appearing -- makes
    // the old selection meaningless, and out of range if the list got shorter.
    onResultsChanged: root.selected = 0

    // The overlay centres what it is given, so this reserves the height of a
    // full list and keeps it: a card that shrank with the results would drag
    // the search box down the screen as you typed.
    Item {
        implicitWidth: root.cardWidth
        implicitHeight: root.searchHeight + root.maxRows * root.rowHeight

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: root.searchHeight + list.height
            color: Theme.background
            border.width: 1
            border.color: Theme.border
            radius: Theme.popupRadius

            Item {
                id: search

                width: parent.width
                height: root.searchHeight

                TextInput {
                    id: input

                    anchors.fill: parent
                    anchors.leftMargin: root.cardPadding
                    anchors.rightMargin: root.cardPadding
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.background
                    font.family: Theme.popupFontFamily
                    font.pointSize: Theme.popupFontSize + 2
                    clip: true
                    focus: true

                    Keys.onDownPressed: root.move(1)
                    Keys.onUpPressed: root.move(-1)
                    Keys.onReturnPressed: root.launch()
                    Keys.onEnterPressed: root.launch()
                    Keys.onTabPressed: root.move(1)
                    Keys.onBacktabPressed: root.move(-1)

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
                // Keeps the keyboard cursor on screen once the list is longer
                // than the eight rows the popup shows.
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                // A new result set starts at the top. Without this a list left
                // scrolled down -- by the wheel, which moves no selection --
                // stays there and hides the row that is actually selected.
                onModelChanged: positionViewAtBeginning()

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index

                    width: list.width
                    height: root.rowHeight
                    color: index === root.selected ? Theme.hover : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: root.cardPadding
                        anchors.rightMargin: root.cardPadding
                        spacing: 12

                        IconImage {
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(row.modelData.icon, true)
                            implicitSize: root.iconSize
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - parent.spacing - root.iconSize

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
                                text: row.modelData.genericName
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
                        // Only a pointer that actually moved picks a row.
                        // Plain enter also fires when the list scrolls under a
                        // still pointer, which dragged the selection back under
                        // the mouse on every arrow key.
                        onPositionChanged: root.selected = row.index
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

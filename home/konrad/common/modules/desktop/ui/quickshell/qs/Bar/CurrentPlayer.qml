import QtQuick
import qs.Common
import qs.Ui

BarItem {
    id: root

    readonly property string identity: (Players.current?.identity ?? "").toLowerCase()

    readonly property var icons: ({
            spotify: "",
            firefox: "",
            discord: "󰙯"
        })

    function iconFor(name) {
        for (const key in icons)
            if (name.includes(key))
                return icons[key];
        return "";
    }

    text: {
        const icon = Players.current ? (root.iconFor(identity) || "") : "󰝛";
        return Players.count > 1 ? icon + " +" + (Players.count - 1) : icon;
    }
    tooltip: Players.current ? Players.current.identity + " (" + Players.count + " available)" : "No player active"

    onLeftClicked: Players.shift(1)
    onRightClicked: Players.shift(-1)
}

import QtQuick
import Quickshell.Bluetooth
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property int connections: Bluetooth.devices.values.filter(d => d.connected).length

    active: adapter !== null
    text: !powered ? "󰂲" : connections > 0 ? "󰂱" : "󰂯"
    tooltip: "Devices connected: " + connections

    onLeftClicked: Cmd.term(Env.bluetoothTui)
    onRightClicked: if (adapter)
        adapter.enabled = !adapter.enabled
}

import QtQuick
import qs.Common
import qs.Config
import qs.Ui

BarItem {
    text: ""
    color: Theme.accent
    tooltip: Env.distro

    onLeftClicked: Shell.launcherOpen = !Shell.launcherOpen
}

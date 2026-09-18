import Quickshell
import Quickshell.Hyprland
import qs.Common
import qs.Notifications
import qs.Panels
import "Bar"

ShellRoot {
    Bar {}

    Popups {}

    Launcher {}

    PowerPanel {}

    // Bound in hyprland as `hl.dsp.global("quickshell:launcher")`, so opening the
    // launcher costs a compositor message rather than a process launch.
    GlobalShortcut {
        appid: "quickshell"
        name: "launcher"
        description: "Open the application launcher"

        onPressed: Shell.launcherOpen = !Shell.launcherOpen
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "power"
        description: "Open the power menu"

        onPressed: Shell.powerOpen = !Shell.powerOpen
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "dismiss"
        description: "Dismiss the oldest notification"

        onPressed: Notifs.dismissOldest()
    }
}

pragma Singleton
import Quickshell
import Quickshell.Hyprland

// The bar and the global shortcuts both open these and neither can reach the
// other's objects, so the state lives on its own.
Singleton {
    property bool launcherOpen: false
    property bool powerOpen: false

    // Idle is one switch for the machine, but the bar it is toggled from is
    // drawn once per screen, so the state cannot live in the widget.
    property bool idleInhibited: false

    // Where a window that belongs to the session rather than to a screen goes.
    // Falls back to the first screen, because hyprland reports no focus while
    // it is still working out the monitor it just gained.
    readonly property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    function closeAll() {
        launcherOpen = false;
        powerOpen = false;
    }
}

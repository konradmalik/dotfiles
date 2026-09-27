pragma Singleton
import Quickshell
import Quickshell.Hyprland

// State that belongs to the session rather than to any one widget: things the
// bar and the global shortcuts both touch, and things there is only one of
// however many screens the bar is drawn on.
Singleton {
    property bool launcherOpen: false
    property bool powerOpen: false

    // Whether the tray is showing its icons. Deliberately a plain property: it
    // is meant to be forgotten when the shell restarts -- which starts it
    // expanded again -- and it is one tray however many bars are drawing it.
    property bool trayExpanded: true

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

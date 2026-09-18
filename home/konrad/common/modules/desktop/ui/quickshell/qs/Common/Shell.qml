pragma Singleton
import Quickshell

// The bar and the global shortcuts both open these and neither can reach the
// other's objects, so the state lives on its own.
Singleton {
    property bool launcherOpen: false
    property bool powerOpen: false

    function closeAll() {
        launcherOpen = false;
        powerOpen = false;
    }
}

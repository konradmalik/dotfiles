pragma Singleton
import Quickshell
import qs.Config

Singleton {
    function run(argv) {
        Quickshell.execDetached(argv);
    }

    function term(command) {
        Quickshell.execDetached(Env.terminalArgv.concat([command]));
    }
}

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

    // Every json this shell reads comes off a process that is allowed to fail,
    // print a warning first, or be halfway through writing, so no caller wants
    // a parse error thrown at it -- they want the fallback and their old value.
    function json(text, fallback) {
        try {
            return JSON.parse(text);
        } catch (e) {
            return fallback;
        }
    }
}

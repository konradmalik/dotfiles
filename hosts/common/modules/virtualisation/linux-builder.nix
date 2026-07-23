{
  lib,
  pkgs,
  ...
}:
let
  # /tmp so the console log self-cleans (macOS reaps it after ~3 days idle)
  # instead of growing unbounded; launchd recreates it on each start.
  logFile = "/tmp/linux-builder.log";
  # start/stop/restart/status helper for the on-demand linux-builder VM
  linux-builder-ctl = pkgs.writeShellApplication {
    name = "linux-builder-ctl";
    text = ''
      label="system/org.nixos.linux-builder"

      case "''${1:-status}" in
        start)
          sudo launchctl kickstart "$label" && echo "linux-builder: started"
          ;;
        stop)
          sudo launchctl kill TERM "$label" && echo "linux-builder: stopped"
          ;;
        restart)
          sudo launchctl kickstart -k "$label" && echo "linux-builder: restarted"
          ;;
        status)
          if sudo launchctl print "$label" 2>/dev/null | grep -q "state = running"; then
            echo "linux-builder: running"
          else
            echo "linux-builder: stopped"
          fi
          ;;
        logs)
          # follow the VM console/boot log; optional arg = initial lines (default 100)
          sudo tail -n "''${2:-100}" -F ${logFile}
          ;;
        *)
          echo "usage: linux-builder-ctl {start|stop|restart|status|logs [lines]}" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [ linux-builder-ctl ];

  # Default the builder to stopped; start it on demand with `linux-builder-ctl`.
  launchd.daemons.linux-builder.serviceConfig = {
    RunAtLoad = lib.mkForce false;
    KeepAlive = lib.mkForce false;
    # capture the VM console/boot output so `linux-builder-ctl logs` can tail it
    StandardOutPath = logFile;
    StandardErrorPath = logFile;
  };

  nix.linux-builder = {
    # sudo ssh linux-builder
    enable = true;
    ephemeral = true;
    config = {
      virtualisation = {
        cores = 6;
        darwin-builder = {
          memorySize = 8 * 1024;
          diskSize = 60 * 1024;
        };
      };
    };
  };
}

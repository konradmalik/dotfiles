{
  lib,
  pkgs,
  inputs,
  ...
}:
let
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
          # vzvm sends the guest console to macOS unified logging
          # no arg: follow live; arg = historical window, e.g. `logs 1h`
          pred='subsystem == "systems.applicative.vzvm"'
          if [ -n "''${2:-}" ]; then
            log show --last "$2" --predicate "$pred"
          else
            log stream --predicate "$pred"
          fi
          ;;
        *)
          echo "usage: linux-builder-ctl {start|stop|restart|status|logs [duration]}" >&2
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
  };

  # vzvm: back the builder with Apple's Virtualization.framework instead of QEMU.
  nixpkgs.overlays = [ inputs.vzvm.overlays.default ];

  nix.linux-builder = {
    # sudo ssh linux-builder
    enable = true;
    package = pkgs.darwin.linux-builder-vz;
    ephemeral = true;
    # x86_64-linux via Rosetta (needs `softwareupdate --install-rosetta` on the host)
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    config = {
      virtualisation = {
        cores = 6;
        # mkForce: the vzvm profile pins these at normal priority
        memorySize = lib.mkForce (8 * 1024); # MiB
        diskSize = lib.mkForce (60 * 1024); # MiB
      };
    };
  };
}

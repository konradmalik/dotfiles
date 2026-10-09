{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.konrad.hyprland.monitors;
  names = lib.attrNames cfg.profiles;
  patterns = lib.concatMapStringsSep "|" lib.escapeShellArg names;

  switcher = pkgs.writeShellApplication {
    name = "monitors";
    text = ''
      case "''${1:-}" in
      ${patterns}) hyprctl eval "require('monitors').apply('$1')" ;;
      *)
        echo "usage: monitors <profile>" >&2
        echo "profiles: ${toString names}" >&2
        exit 2
        ;;
      esac
    '';
  };
in
{
  options.konrad.hyprland.monitors = {
    enable = lib.mkEnableOption "laptop panel profiles that follow external monitors";

    panel = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Output name of the built-in panel.";
    };

    profiles = lib.mkOption {
      type = with lib.types; attrsOf (attrsOf anything);
      description = ''
        Profile name to the `hl.monitor` fields it sets on the panel. The rest
        default to on, preferred mode, scale 1, left of any external. A
        `mirror = "external"` mirrors whichever external monitor is connected.
      '';
    };

    connected = lib.mkOption {
      type = lib.types.str;
      default = "docked";
      description = "Profile applied when an external monitor is connected.";
    };

    disconnected = lib.mkOption {
      type = lib.types.str;
      default = "laptop";
      description = "Profile applied when no external monitor is connected.";
    };
  };

  config = lib.mkIf cfg.enable {
    konrad.hyprland.monitors.profiles = lib.mapAttrs (_: lib.mkDefault) {
      laptop = { };
      docked.disabled = true;
      mirror.mirror = "external";
    };

    assertions = [
      {
        assertion = cfg.profiles ? ${cfg.connected} && cfg.profiles ? ${cfg.disconnected};
        message = "konrad.hyprland.monitors: connected and disconnected must name profiles";
      }
    ];

    home.packages = [ switcher ];

    wayland.windowManager.hyprland.extraLuaFiles = {
      monitors = ./monitors.lua;
      "monitors.config" = {
        autoLoad = false;
        content = "return ${
          lib.generators.toLua { } {
            inherit (cfg)
              panel
              profiles
              connected
              disconnected
              ;
          }
        }";
      };
    };
  };
}

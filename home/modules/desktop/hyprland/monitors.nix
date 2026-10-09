{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.konrad.hyprland.monitors;

  # Taken from https://github.com/NixOS/nixpkgs/pull/572107, drop once merged.
  hyprmoncfg =
    (builtins.getFlake "github:konradmalik/nixpkgs/0a5a7afce688a1a75bd317f234455f2689c69a9c")
    .legacyPackages.${pkgs.stdenv.hostPlatform.system}.hyprmoncfg;
in
{
  options.konrad.hyprland.monitors = {
    enable = lib.mkEnableOption "hyprmoncfg, switching monitor layouts by profile";

    profiles = lib.mkOption {
      type = with lib.types; attrsOf (listOf (attrsOf anything));
      default = { };
      description = ''
        Declarative hyprmoncfg profiles: name to the list of its outputs. An
        output needs only `key` (`hyprmoncfg monitors` lists them), the rest
        defaults to enabled at 0x0, scale 1, preferred mode. Nix owns these: one
        edited in the TUI is overwritten on the next switch. Profiles saved
        under a new name in the TUI are left alone.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ hyprmoncfg ];

    xdg.configFile = lib.mapAttrs' (
      name: outputs:
      lib.nameValuePair "hyprmoncfg/profiles/${name}.json" {
        text = builtins.toJSON {
          inherit name;
          outputs = map (
            output:
            {
              enabled = true;
              x = 0;
              y = 0;
              scale = 1;
            }
            // output
          ) outputs;
        };
        force = true;
      }
    ) cfg.profiles;

    # hyprmoncfg verifies this is the very last line, so its rules win
    wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
      -- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
      do local path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
    '';

    systemd.user.services.hyprmoncfgd = {
      Unit = {
        Description = "Hyprland monitor profile daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        # lid and monitor changes arrive as UPower and Hyprland events; the
        # default 1s/5s fallback polls cost ~100 wakeups/s, so poll rarely
        ExecStart = "${lib.getExe' hyprmoncfg "hyprmoncfgd"} --lid-poll-interval 1m --poll-interval 1m";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

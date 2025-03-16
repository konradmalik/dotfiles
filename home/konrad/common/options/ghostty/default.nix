{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.ghostty;
in
{
  options.konrad.programs.ghostty = {
    enable = mkEnableOption "Enables Ghostty configuration management through home-manager";

    makeDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to make this terminal default by setting TERMINAL env var";
    };

    fontSize = mkOption {
      type = types.nullOr types.number;
      default = config.fontProfiles.monospace.size;
      example = "13.0";
      description = "Font size. If null, ghostty will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.nullOr types.str;
      default = config.fontProfiles.monospace.family;
      example = default;
      description = "Font Family to use. If null, ghostty will set it automatically.";
    };

    theme = mkOption {
      type = types.nullOr types.str;
      default = config.colorscheme.name;
      example = "JetBrains Dracula";
      description = "Theme to use. See 'ghosty +list-themes'";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.ghostty;
      description = "Package for ghostty. If null, it won't be installed.";
      example = "pkgs.ghostty";
    };
  };

  config =
    let
      baseConfig = pkgs.callPackage ./config.nix { inherit (cfg) fontFamily fontSize theme; };
    in
    mkMerge [
      (mkIf cfg.enable {
        home = {
          sessionVariables.TERMINAL = mkIf cfg.makeDefault "ghostty";
          packages = lib.optional (cfg.package != null) cfg.package;
        };
        xdg.configFile."ghostty/config".text = baseConfig;
      })
      (mkIf (!cfg.enable) {
        home.packages = lib.optional (cfg.package != null) cfg.package.terminfo;
      })
    ];
}

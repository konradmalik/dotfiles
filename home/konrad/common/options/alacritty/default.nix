{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.alacritty;
in
{
  options.konrad.programs.alacritty = {
    enable = mkEnableOption "Enables Alacritty configuration management through home-manager";

    makeDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to make this terminal default by setting TERMINAL env var";
    };

    fontSize = mkOption {
      type = types.number;
      default = config.fontProfiles.monospace.size;
      example = "13.0";
      description = "Font size. If 0, alacritty will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.str;
      default = config.fontProfiles.monospace.family;
      example = default;
      description = "Font Family to use. If null, alacritty will set it automatically.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.alacritty;
      description = "Package for alacritty. If null, it won't be installed.";
      example = "pkgs.alacritty";
    };

    colorscheme = mkOption {
      type = types.nullOr types.attrs;
      default = config.colorscheme;
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "config.colorscheme";
    };
  };

  config =
    let
      baseConfig = pkgs.callPackage ./config.nix { inherit (cfg) fontFamily fontSize; };
      colorConfig = import ./theme.nix { inherit (cfg) colorscheme; };
    in
    mkIf cfg.enable {
      home = {
        packages = lib.optional (cfg.package != null) cfg.package;
        sessionVariables.TERMINAL = mkIf cfg.makeDefault "alacritty";
      };

      xdg.configFile."alacritty/alacritty.toml".text = lib.concatStringsSep "\n" (
        [ baseConfig ] ++ lib.optional (cfg.colorscheme != null) colorConfig
      );

      programs.tmux.extraConfig = ''
        # overrides for the alacritty (host) terminal features
        # to print the detected ones (including set ones): tmux display -p '#{client_termfeatures}'
        set -as terminal-features ",alacritty*:RGB:hyperlinks:strikethrough:usstyle"
      '';
    };
}

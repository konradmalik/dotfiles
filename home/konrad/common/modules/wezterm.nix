{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.wezterm;
in
{
  options.konrad.programs.wezterm = {
    enable = mkEnableOption "Enables Wezterm configuration management through home-manager";

    makeDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to make this terminal default by setting TERMINAL env var";
    };

    fontSize = mkOption {
      type = types.number;
      default = config.fontProfiles.monospace.size;
      example = "13.0";
      description = "Font size. If 0, wezterm will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.str;
      default = config.fontProfiles.monospace.family;
      example = default;
      description = "Font Family to use. If null, wezterm will set it automatically.";
    };

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.wezterm;
      description = "Package for wezterm. If null, it won't be installed.";
      example = "pkgs.wezterm";
    };

    colorscheme = lib.mkOption {
      type = types.str;
      default = "Kanagawa (Gogh)";
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "Kanagawa (Gogh)";
    };
  };

  config =
    let
      baseConfig = ''
        local wezterm = require('wezterm')

        local config = wezterm.config_builder()

        config.font_size = ${toString cfg.fontSize}
        config.font = wezterm.font '${cfg.fontFamily}'
        config.color_scheme = '${cfg.colorscheme}'
        config.hide_tab_bar_if_only_one_tab = true

        return config
      '';
    in
    mkIf cfg.enable {
      home = {
        packages = lib.optional (cfg.package != null) cfg.package;
        sessionVariables.TERMINAL = mkIf cfg.makeDefault "wezterm";
      };

      xdg.configFile."wezterm/wezterm.lua".text = baseConfig;
    };
}

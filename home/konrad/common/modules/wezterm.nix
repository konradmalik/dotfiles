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
      type = lib.types.nullOr lib.types.attrs;
      default = config.colorscheme;
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "config.colorscheme";
    };
  };

  config =
    let
      colors = pkgs.writeText "wezterm-colorscheme"
        ''
          scheme: "${config.colorscheme.name}"
          author: "${config.colorscheme.author}"
          base00: "#${cfg.colorscheme.colors.base00}"
          base01: "#${cfg.colorscheme.colors.base01}"
          base02: "#${cfg.colorscheme.colors.base02}"
          base03: "#${cfg.colorscheme.colors.base03}"
          base04: "#${cfg.colorscheme.colors.base04}"
          base05: "#${cfg.colorscheme.colors.base05}"
          base06: "#${cfg.colorscheme.colors.base06}"
          base07: "#${cfg.colorscheme.colors.base07}"
          base08: "#${cfg.colorscheme.colors.base08}"
          base09: "#${cfg.colorscheme.colors.base09}"
          base0A: "#${cfg.colorscheme.colors.base0A}"
          base0B: "#${cfg.colorscheme.colors.base0B}"
          base0C: "#${cfg.colorscheme.colors.base0C}"
          base0D: "#${cfg.colorscheme.colors.base0D}"
          base0E: "#${cfg.colorscheme.colors.base0E}"
          base0F: "#${cfg.colorscheme.colors.base0F}"
        '';
      baseConfig = ''
        local wezterm = require('wezterm')

        local config = wezterm.config_builder()

        config.font_size = ${toString cfg.fontSize}
        config.font = wezterm.font('${cfg.fontFamily}')
        colors, metadata = wezterm.color.load_base16_scheme('${colors}')
        config.colors = colors
        config.hide_tab_bar_if_only_one_tab = true
        config.window_close_confirmation = 'NeverPrompt'

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

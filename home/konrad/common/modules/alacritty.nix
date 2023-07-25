{ config, lib, pkgs, ... }:
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

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.alacritty;
      description = "Package for alacritty. If null, it won't be installed.";
      example = "pkgs.alacritty";
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
      baseConfig = ''
        window:
          dynamic_title: true
          padding:
            x: 2
            y: 1
          dynamic_padding: true

        cursor:
          style:
            shape: Block

        fontfamily: &fontfamily "${cfg.fontFamily}"
        font:
          size: ${toString cfg.fontSize}
          normal:
            family: *fontfamily
            style: Regular

          bold:
            family: *fontfamily
            style: Bold

          italic:
            family: *fontfamily
            style: Italic

          bold_italic:
            family: *fontfamily
            style: Bold Italic
      '';
      colorConfig = ''
        # Base16 ${cfg.colorscheme.slug} - alacritty color config
        colors:
          # Default colors
          primary:
            background: '#${cfg.colorscheme.colors.base00}'
            foreground: '#${cfg.colorscheme.colors.base05}'
            dim_foreground: '#${cfg.colorscheme.colors.base05}'
            bright_foreground: '#${cfg.colorscheme.colors.base05}'

          # Colors the cursor will use if `custom_cursor_colors` is true
          cursor:
            text: '#${cfg.colorscheme.colors.base00}'
            cursor: '#${cfg.colorscheme.colors.base06}'
          vi_mode_cursor:
            text: '#${cfg.colorscheme.colors.base00}'
            cursor: '#${cfg.colorscheme.colors.base07}'

          # Search colors
          search:
              matches:
                  foreground: '#${cfg.colorscheme.colors.base00}'
                  background: '#${cfg.colorscheme.colors.base04}'
              focused_match:
                  foreground: '#${cfg.colorscheme.colors.base00}'
                  background: '#${cfg.colorscheme.colors.base0B}'
              footer_bar:
                  foreground: '#${cfg.colorscheme.colors.base00}'
                  background: '#${cfg.colorscheme.colors.base04}'

          # Keyboard regex hints
          hints:
              start:
                  foreground: '#${cfg.colorscheme.colors.base00}'
                  background: '#${cfg.colorscheme.colors.base0A}'
              end:
                  foreground: '#${cfg.colorscheme.colors.base00}'
                  background: '#${cfg.colorscheme.colors.base04}'

          # Selection colors
          selection:
              text: '#${cfg.colorscheme.colors.base00}'
              background: '#${cfg.colorscheme.colors.base06}'

          # Normal colors
          normal:
            black:   '#${cfg.colorscheme.colors.base03}'
            red:     '#${cfg.colorscheme.colors.base08}'
            green:   '#${cfg.colorscheme.colors.base0B}'
            yellow:  '#${cfg.colorscheme.colors.base0A}'
            blue:    '#${cfg.colorscheme.colors.base0D}'
            magenta: '#${cfg.colorscheme.colors.base0F}'
            cyan:    '#${cfg.colorscheme.colors.base0C}'
            white:   '#${cfg.colorscheme.colors.base05}'

          # Bright colors
          bright:
            black:   '#${cfg.colorscheme.colors.base04}'
            red:     '#${cfg.colorscheme.colors.base08}'
            green:   '#${cfg.colorscheme.colors.base0B}'
            yellow:  '#${cfg.colorscheme.colors.base0A}'
            blue:    '#${cfg.colorscheme.colors.base0D}'
            magenta: '#${cfg.colorscheme.colors.base0F}'
            cyan:    '#${cfg.colorscheme.colors.base0C}'
            white:   '#${cfg.colorscheme.colors.base05}'

          # Dim colors
          dim:
            black:   '#${cfg.colorscheme.colors.base03}'
            red:     '#${cfg.colorscheme.colors.base08}'
            green:   '#${cfg.colorscheme.colors.base0B}'
            yellow:  '#${cfg.colorscheme.colors.base0A}'
            blue:    '#${cfg.colorscheme.colors.base0D}'
            magenta: '#${cfg.colorscheme.colors.base0F}'
            cyan:    '#${cfg.colorscheme.colors.base0C}'
            white:   '#${cfg.colorscheme.colors.base05}'

          indexed_colors:
              - { index: 16, color: "#${cfg.colorscheme.colors.base09}" }
              - { index: 17, color: "#${cfg.colorscheme.colors.base06}" }
      '';
    in
    mkIf cfg.enable {
      home = {
        packages = lib.optional (cfg.package != null) cfg.package;
        sessionVariables.TERMINAL = mkIf cfg.makeDefault "alacritty";
      };

      xdg.configFile."alacritty/alacritty.yml".text =
        lib.concatStringsSep "\n" ([ baseConfig ] ++ lib.optional (cfg.colorscheme != null) colorConfig);
    };
}

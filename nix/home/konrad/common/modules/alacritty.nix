{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.alacritty;
  # TODO move whole alacritty here and use base16
in
{
  options.konrad.programs.alacritty = {
    enable = mkEnableOption "Enables Alacritty configuration management through home-manager";

    fontSize = mkOption {
      type = types.number;
      default = 0;
      example = "13.0";
      description = "Font size. If default, alacritty will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.str;
      default = config.konrad.fontProfiles.monospace.family;
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
            blinking: Always

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
            background: '0x${cfg.colorscheme.colors.base00}'
            foreground: '0x${cfg.colorscheme.colors.base05}'

          # Colors the cursor will use if `custom_cursor_colors` is true
          cursor:
            text: '0x${cfg.colorscheme.colors.base00}'
            cursor: '0x${cfg.colorscheme.colors.base05}'

          # Normal colors
          normal:
            black:   '0x${cfg.colorscheme.colors.base00}'
            red:     '0x${cfg.colorscheme.colors.base08}'
            green:   '0x${cfg.colorscheme.colors.base0B}'
            yellow:  '0x${cfg.colorscheme.colors.base0A}'
            blue:    '0x${cfg.colorscheme.colors.base0D}'
            magenta: '0x${cfg.colorscheme.colors.base0E}'
            cyan:    '0x${cfg.colorscheme.colors.base0C}'
            white:   '0x${cfg.colorscheme.colors.base05}'

          # Bright colors
          bright:
            black:   '0x${cfg.colorscheme.colors.base03}'
            red:     '0x${cfg.colorscheme.colors.base09}'
            green:   '0x${cfg.colorscheme.colors.base01}'
            yellow:  '0x${cfg.colorscheme.colors.base02}'
            blue:    '0x${cfg.colorscheme.colors.base04}'
            magenta: '0x${cfg.colorscheme.colors.base06}'
            cyan:    '0x${cfg.colorscheme.colors.base0F}'
            white:   '0x${cfg.colorscheme.colors.base07}'

        draw_bold_text_with_bright_colors: false
      '';
    in
    mkIf cfg.enable {
      home.packages = lib.optional (cfg.package != null) cfg.package;

      xdg.configFile."alacritty/alacritty.yml".text =
        lib.concatStringsSep "\n" ([ baseConfig ] ++ lib.optional (cfg.colorscheme != null) colorConfig);
    };
}
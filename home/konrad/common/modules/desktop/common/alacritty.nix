{
  config,
  lib,
  pkgs,
  ...
}:
let
  c = config.colorscheme.palette;
  fontSize = config.fontProfiles.monospace.size;
  fontFamily = config.fontProfiles.monospace.family;
in
{
  programs.tmux.extraConfig = ''
    # overrides for the alacritty (host) terminal features
    set -as terminal-features ",alacritty*:RGB:hyperlinks:strikethrough:usstyle"
  '';

  programs.alacritty = {
    enable = lib.mkDefault true;

    settings = {
      general.live_config_reload = false;

      font = {
        size = fontSize;
        normal = {
          family = fontFamily;
          style = "Regular";
        };
        bold = {
          family = fontFamily;
          style = "Bold";
        };
        italic = {
          family = fontFamily;
          style = "Italic";
        };
        "bold_italic" = {
          family = fontFamily;
          style = "Bold Italic";
        };
      };

      mouse.hide_when_typing = true;
      scrolling.history = 5000;

      window = {
        blur = true;
        dynamic_padding = false;
        dynamic_title = true;
        padding = {
          x = 6;
          y = 6;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        "option_as_alt" = "Both";
      };

      colors = {
        primary = {
          background = "#${c.base00}";
          foreground = "#${c.base05}";
          bright_foreground = "#${c.base05}";
          dim_foreground = "#${c.base05}";
        };
        normal = {
          black = "#${c.base03}";
          red = "#${c.base08}";
          green = "#${c.base0B}";
          yellow = "#${c.base0A}";
          blue = "#${c.base0D}";
          magenta = "#${c.base0F}";
          cyan = "#${c.base0C}";
          white = "#${c.base05}";
        };
        bright = {
          black = "#${c.base04}";
          red = "#${c.base08}";
          green = "#${c.base0B}";
          yellow = "#${c.base0A}";
          blue = "#${c.base0D}";
          magenta = "#${c.base0F}";
          cyan = "#${c.base0C}";
          white = "#${c.base05}";
        };
        dim = {
          black = "#${c.base03}";
          red = "#${c.base08}";
          green = "#${c.base0B}";
          yellow = "#${c.base0A}";
          blue = "#${c.base0D}";
          magenta = "#${c.base0F}";
          cyan = "#${c.base0C}";
          white = "#${c.base05}";
        };
        cursor = {
          cursor = "#${c.base06}";
          text = "#${c.base00}";
        };
        vi_mode_cursor = {
          cursor = "#${c.base07}";
          text = "#${c.base00}";
        };
        selection = {
          background = "#${c.base06}";
          text = "#${c.base00}";
        };
        search = {
          matches = {
            background = "#${c.base04}";
            foreground = "#${c.base00}";
          };
          focused_match = {
            background = "#${c.base0B}";
            foreground = "#${c.base00}";
          };
        };
        hints = {
          start = {
            background = "#${c.base0A}";
            foreground = "#${c.base00}";
          };
          end = {
            background = "#${c.base04}";
            foreground = "#${c.base00}";
          };
        };
        footer_bar = {
          background = "#${c.base04}";
          foreground = "#${c.base00}";
        };
        indexed_colors = [
          {
            index = 16;
            color = "#${c.base09}";
          }
          {
            index = 17;
            color = "#${c.base06}";
          }
        ];
      };
    };
  };
}

{
  config,
  inputs,
  ...
}:
let
  fontFamily = config.fontProfiles.monospace.family;
  palette = config.colorscheme.palette;
  convert = inputs.nix-colors.lib.conversions.hexToRGBString;

  surfaceRgb = "rgb(${convert ", " palette.base02})";
  foregroundRgb = "rgb(${convert ", " palette.base05})";
  foregroundMutedRgb = "rgb(${convert ", " palette.base04})";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        no_fade_in = false;
      };
      background = {
        monitor = "";
        path = config.konrad.wallpaper;
      };

      input-field = {
        monitor = "";
        size = "600, 100";
        position = "0, 0";
        halign = "center";
        valign = "center";

        inner_color = surfaceRgb;
        outer_color = foregroundRgb;
        outline_thickness = 4;

        font_family = fontFamily;
        font_size = 32;
        font_color = foregroundRgb;

        placeholder_color = foregroundMutedRgb;
        placeholder_text = "   Screen locked";
        check_color = "rgba(131, 192, 146, 1.0)";
        fail_text = "   Wrong ";

        rounding = 0;
        shadow_passes = 0;
        fade_on_empty = false;
      };

      label = {
        monitor = "";
        text = "\$FPRINTPROMPT";
        text_align = "center";
        color = "rgb(211, 198, 170)";
        font_size = 24;
        font_family = fontFamily;
        position = "0, -100";
        halign = "center";
        valign = "center";
      };
    };
  };
}

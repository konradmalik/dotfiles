{ config, lib, ... }:
let
  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors.withHashtag;
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        animation = [
          "fadeOut, 0, 1, linear"
        ];
      };

      background = {
        blur_passes = 2;
        path = lib.mkForce "screenshot";
      };

      label = {
        text = "$TIME";
        color = colors.base05;
        font_family = fonts.sansSerif.name;
        font_size = 90;
        position = "0, 180";
        halign = "center";
        valign = "center";
      };

      input-field = {
        size = "600, 100";

        font_family = fonts.monospace.name;
        placeholder_text = "   Screen locked";
        fail_text = "   Wrong ($ATTEMPTS)";

        rounding = 4;
        fade_on_empty = false;
        dots_center = true;
      };
    };
  };
}

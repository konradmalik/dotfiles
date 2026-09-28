{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  fonts = config.stylix.fonts;
  colors = config.lib.stylix.colors;
  rgb = c: "rgb(${c})";

  date = lib.getExe' pkgs.coreutils "date";
  lcTime = osConfig.i18n.extraLocaleSettings.LC_TIME or "C.UTF-8";

  shadow = {
    shadow_passes = 2;
    shadow_size = 4;
    shadow_color = "rgba(0, 0, 0, 0.5)";
  };
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

      label = [
        (
          shadow
          // {
            text = "$TIME";
            color = rgb colors.base05;
            font_family = "${fonts.monospace.name} Bold";
            font_size = 150;
            position = "0, 240";
            halign = "center";
            valign = "center";
          }
        )
        (
          shadow
          // {
            text = "cmd[update:60000] LC_TIME=${lcTime} ${date} +'%A, %-d %B'";
            color = rgb colors.base04;
            font_family = fonts.sansSerif.name;
            font_size = 18;
            position = "0, 125";
            halign = "center";
            valign = "center";
          }
        )
      ];

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

{ config, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        blur_passes = 1;
      };

      input-field = {
        size = "600, 100";

        placeholder_text = "   Screen locked";
        fail_text = "   Wrong ";

        rounding = 4;
        fade_on_empty = false;
      };

      image = {
        path = "${config.home.homeDirectory}/${config.home.file.".face".target}";
        size = "150,150";
        position = "0, 150";
      };
    };
  };
}

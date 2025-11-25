{
  pkgs,
  lib,
  ...
}:
{
  stylix = {
    enable = true;
    autoEnable = true;

    image = lib.mkDefault ../../../../files/wallpapers/nature-landscape-forest-path-wallpaper.jpg;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    polarity = "dark";

    fonts = rec {
      serif = sansSerif;

      sansSerif = {
        package = pkgs.ubuntu-sans;
        name = "Ubuntu Sans";
      };

      monospace = {
        package = pkgs.custom.fonts.iosemka;
        name = "Iosemka Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = lib.mkDefault 12;
        desktop = lib.mkDefault 10;
        terminal = lib.mkDefault 13;
        popups = lib.mkDefault 15;
      };
    };
  };
}

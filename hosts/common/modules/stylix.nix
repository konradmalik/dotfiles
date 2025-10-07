{
  pkgs,
  lib,
  customArgs,
  ...
}:
{
  stylix = {
    enable = true;
    autoEnable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    polarity = "dark";

    image = "${customArgs.files}/wallpapers/bishal-mishra.jpg";

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = lib.mkDefault 8;
    };

    fonts = rec {
      serif = sansSerif;

      sansSerif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = lib.mkDefault 10;
        desktop = lib.mkDefault 10;
        terminal = lib.mkDefault 13;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}

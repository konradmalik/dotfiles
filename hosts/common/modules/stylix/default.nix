{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./shared.nix ];

  # not supported by nix-darwin
  stylix = {
    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = lib.mkDefault 8;
    };
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}

{ config, ... }:
let
  c = config.colorscheme;
in
{
  services.mako = {
    enable = true;
    iconPath =
      if c.variant == "dark" then
        "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
      else
        "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
    font = "${config.fontProfiles.regular.family} ${toString config.fontProfiles.regular.size}";
    padding = "10,20";
    anchor = "top-center";
    width = 400;
    height = 150;
    borderSize = 2;
    defaultTimeout = 12000;
    backgroundColor = "#${c.palette.base00}dd";
    borderColor = "#${c.palette.base03}dd";
    textColor = "#${c.palette.base05}dd";
  };
}

{ config, ... }:
let
  c = config.colorscheme;
in
{
  wayland.windowManager.hyprland.settings.exec-once = [ "mako" ];

  services.mako = {
    enable = true;
    settings = {
      icon-path =
        if c.variant == "dark" then
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      font = "${config.fontProfiles.regular.family} ${toString config.fontProfiles.regular.size}";
      padding = "10,20";
      anchor = "top-center";
      width = 400;
      height = 150;
      border-size = 2;
      default-timeout = 12000;
      background-color = "#${c.palette.base00}dd";
      border-color = "#${c.palette.base03}dd";
      text-color = "#${c.palette.base05}dd";
    };
  };
}

{ config, ... }:
let
  c = config.colorscheme;
in
{
  wayland.windowManager.hyprland.settings.exec-once = [ "mako" ];

  services.mako = {
    enable = true;
    settings = {
      background-color = "#${c.palette.base00}dd";
      border-color = "#${c.palette.base03}dd";
      progress-color = "#${c.palette.base0D}";
      text-color = "#${c.palette.base05}dd";

      icon-path =
        if c.variant == "dark" then
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      font = "${config.fontProfiles.regular.family} ${toString config.fontProfiles.regular.size}";

      anchor = "top-center";
      layer = "overlay";

      width = 400;
      height = 150;
      border-size = 2;
      padding = "10,20";

      default-timeout = 10000;
      ignore-timeout = false;
      max-visible = 5;
      sort = "-time";
      group-by = "app-name";

      actions = true;

      format = "<b>%s</b>\\n%b";
      markup = true;
    };
  };
}

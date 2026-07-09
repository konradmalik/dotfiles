{ config, ... }:
let
  icons = config.stylix.icons;
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function() hl.exec_cmd("${config.services.mako.package}/bin/mako") end)
  '';

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-center";
      layer = "overlay";

      icons = 1;
      icon-path =
        if config.stylix.polarity == "dark" then
          "${icons.package}/share/icons/${icons.dark}"
        else
          "${icons.package}/share/icons/${icons.light}";

      width = 400;
      height = 150;
      border-size = 2;
      padding = "10,20";

      default-timeout = 10000;
      ignore-timeout = false;
      max-visible = 5;
      max-history = 20;
      sort = "-time";
      group-by = "app-name";

      actions = true;

      format = "<b>%s</b>\\n%b";
      markup = true;

      "mode=do-not-disturb" = {
        invisible = 1;
      };
    };
  };
}

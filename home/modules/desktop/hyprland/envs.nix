{ lib, ... }:
{
  wayland.windowManager.hyprland.settings = {
    #  https://wiki.hypr.land/Configuring/Environment-variables/
    env =
      lib.mapAttrsToList
        (name: value: {
          _args = [
            name
            value
          ];
        })
        {
          GDK_BACKEND = "wayland,x11,*";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          XDG_SESSION_DESKTOP = "Hyprland";
        };

    config.ecosystem = {
      no_update_news = true;
    };
  };
}

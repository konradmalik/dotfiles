{
  wayland.windowManager.hyprland.settings = {
    #  https://wiki.hyprland.org/Configuring/Environment-variables/
    env = [
      "LIBSEAT_BACKEND,logind"
      "GDK_BACKEND,wayland,x11,*"
      "QT_QPA_PLATFORM,wayland;xcb"
      "QT_AUTO_SCREEN_SCALE_FACTOR,1"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "SDL_VIDEODRIVER,wayland"
      "CLUTTER_BACKEND,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
    ];

    ecosystem = {
      no_update_news = true;
    };
  };
}

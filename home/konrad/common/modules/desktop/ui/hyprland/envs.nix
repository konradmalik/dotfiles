{
  wayland.windowManager.hyprland.settings = {
    #  https://wiki.hypr.land/Configuring/Environment-variables/
    env = [
      { _args = [ "LIBSEAT_BACKEND" "logind" ]; }
      { _args = [ "GDK_BACKEND" "wayland,x11,*" ]; }
      { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
      { _args = [ "QT_AUTO_SCREEN_SCALE_FACTOR" "1" ]; }
      { _args = [ "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1" ]; }
      { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
      { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
      { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
    ];

    config.ecosystem = {
      no_update_news = true;
    };
  };
}

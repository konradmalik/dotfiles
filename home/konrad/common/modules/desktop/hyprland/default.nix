{
  pkgs,
  ...
}:
{
  imports = [
    ../common

    ./gammastep.nix
    ./hyprland
    ./mako.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./waybar.nix
    ./wofi.nix
  ];

  home.packages = with pkgs; [
    hyprshot
  ];

  home.sessionVariables = {
    #  https://wiki.hyprland.org/Configuring/Environment-variables/
    LIBSEAT_BACKEND = "logind";
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}

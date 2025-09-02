{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./gammastep.nix
    ./imv.nix
    ./mako.nix
    (import ./swaybg.nix {
      inherit (config.konrad) wallpaper;
      inherit (pkgs) swaybg;
    })
    ./swayidle.nix
    ./waybar.nix
    ./wofi.nix
  ];

  home.packages = with pkgs; [
    grim # screenshots
    libnotify # notify-send
    pavucontrol # audio gui
    playerctl # control audio players system-wide
    slurp # screenshots
    wl-clipboard
    wl-mirror # screen mirroring
    wlr-randr # xrandr for wayland
  ];

  home.sessionVariables = {
    #  https://wiki.hyprland.org/Configuring/Environment-variables/
    LIBSEAT_BACKEND = "logind";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
    QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}

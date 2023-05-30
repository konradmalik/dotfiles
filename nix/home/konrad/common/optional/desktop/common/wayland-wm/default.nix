{ pkgs, ... }:
{
  imports = [
    ./gammastep.nix
    ./imv.nix
    ./mako.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
  ];

  home.packages = with pkgs; [
    grim # screenshots
    hyprland-share-picker
    libnotify # notify-send
    pavucontrol # audio gui
    playerctl # control audio players system-wide
    slurp # screenshots
    waypipe # forward wayland through ssh
    wl-clipboard
    wl-mirror # screen mirroring
    wlr-randr # xrandr for wayland
    ydotool # UI automation
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}

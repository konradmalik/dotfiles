{ pkgs, ... }:
{
  home.packages = [ pkgs.firefox ];

  wayland.windowManager.hyprland.settings = {
    env = [
      "BROWSER,firefox"
    ];
  };
}

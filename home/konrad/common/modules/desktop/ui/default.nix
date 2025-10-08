{
  pkgs,
  ...
}:
{
  imports = [
    ./gammastep.nix
    ./hyprland
    ./mako.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./rofi.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    hyprshot
  ];
}

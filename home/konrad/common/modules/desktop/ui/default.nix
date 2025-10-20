{
  pkgs,
  ...
}:
{
  imports = [
    ./fuzzel.nix
    ./gammastep.nix
    ./hyprland
    ./mako.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./nwg-bar.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    hyprshot
  ];
}

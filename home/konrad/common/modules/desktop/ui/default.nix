{
  pkgs,
  ...
}:
{
  imports = [
    ./fuzzel.nix
    ./hyprland
    ./mako.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprsunset.nix
    ./nwg-bar.nix
    ./waybar
  ];

  home.packages = with pkgs; [
    hyprshot
    swappy
  ];
}

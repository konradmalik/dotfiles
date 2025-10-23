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
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    hyprshot
  ];
}

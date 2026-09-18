{
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprsunset.nix
    ./quickshell
  ];

  home.packages = with pkgs; [
    hyprshot
    swappy
  ];
}

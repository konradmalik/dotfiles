{
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    hyprshot
    swappy
  ];
}

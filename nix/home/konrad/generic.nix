{ config, ... }:
{
  imports = [
    ./global
    ./global/nonnixos.nix
    ./global/gui.nix
  ];

  home = {
    username = "konrad";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

{ config, ... }:
{
  imports = [
    ./global/nonnixos.nix
    ./layers/gui.nix
  ];

  home = {
    username = "konrad";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

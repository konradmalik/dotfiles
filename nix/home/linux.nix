{ config, username, ... }:
{
  imports = [
    ./presets/nonnixos.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

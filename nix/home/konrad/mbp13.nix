{ config, ... }:

{
  imports = [
    ./global
    ./global/darwin.nix
    ./global/gui.nix
  ];

  home = {
    username = "konrad";
    homeDirectory = "/Users/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 16.0;
}


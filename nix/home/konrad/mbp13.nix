{ config, lib, pkgs, ... }:

{
  home = {
    username = "konrad";
    homeDirectory = "/Users/${config.home.username}";
  };

  imports = [
    ./global
    ./global/gui.nix
  ];

  programs.alacritty.settings.font.size = 16.0;
}


{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
    ./modules/sway.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./common/presets/nixos.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

{ config, lib, username, ... }:
{
  imports = [
    ./presets/nonnixos.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

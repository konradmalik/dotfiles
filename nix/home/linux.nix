{ config, lib, username, ... }:
{
  imports = [
    ../hosts/common/nix/shared.nix
    ./presets/nonnixos.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

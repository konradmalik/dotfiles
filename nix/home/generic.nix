{ config, lib, username, ... }:
{
  imports = [
    ../hosts/common/nix/shared.nix
    ./presets/generic.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

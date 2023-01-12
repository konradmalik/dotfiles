{ config, lib, username, ... }:
{
  imports = [
    ../hosts/common/global/nix/shared.nix
    ./common/presets/generic.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };
}

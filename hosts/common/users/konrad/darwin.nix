{ config, pkgs, ... }:
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users.users.konrad = {
    name = "konrad";
    home = "/Users/${config.users.users.konrad.name}";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
  };
}

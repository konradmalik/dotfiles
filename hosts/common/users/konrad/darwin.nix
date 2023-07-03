{ config, pkgs, ... }:
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users.users.konrad = {
    name = "konrad";
    home = "/Users/${config.users.users.konrad.name}";
    shell = pkgs.zsh;
  };


}

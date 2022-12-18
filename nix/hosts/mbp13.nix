{ config, pkgs, ... }:
{
  imports = [
    ./global/default.nix
  ];

  networking.hostName = "mbp13";

  users.users.konrad = {
    name = "konrad";
    home = "/Users/konrad";
    shell = pkgs.zsh;
  };
}

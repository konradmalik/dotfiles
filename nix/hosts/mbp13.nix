{ config, pkgs, ... }:
{
  imports = [
    ./global/darwin.nix
  ];

  networking.hostName = "mbp13";

  users.users.konrad = {
    name = "konrad";
    home = "/Users/konrad";
    shell = pkgs.zsh;
  };
}

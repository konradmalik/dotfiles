{ config, pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ./vm.nix
  ];
}

{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/nixos.nix
    ];

  networking.hostName = "vaio";

  konrad.networking.wireless.enable = true;

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 2;
      max-jobs = 8;
    };
  };

  services.logind.lidSwitch = "ignore";
}
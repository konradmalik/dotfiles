{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/presets/nixos.nix
    ];

  networking.hostName = "xps12";

  konrad.networking.wireless.enable = true;

  nix = {
    settings = {
      min-free = 15374182400; # ~15GB
      max-free = 647374182400; # 64GB
      cores = 2;
      max-jobs = 8;
    };
  };

  services.logind.lidSwitch = "ignore";
}

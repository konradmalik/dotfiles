{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./nixos-server.nix
    ./programs/networkmanager.nix
  ];

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        ReconnectAttempts = 5;
        ReconnectIntervals = "1, 2, 3";
      };
    };
  };

  # enable firewall
  networking.firewall.enable = true;
}

{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/presets/nixos.nix
    ];

  networking.hostName = "xps12";

  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  # enable aarch64-linux emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
    logind.lidSwitch = "ignore";
    rtcwake = {
      enable = true;
      # both UTC
      on = "*-*-* 22:00:00";
      off = "tomorrow 07:00";
      mode = "off";
    };
  };
}

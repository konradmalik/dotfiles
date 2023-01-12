{ config, pkgs, lib, inputs, username, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/presets/nixos.nix
    ];

  networking.hostName = "m3800";

  konrad.programs.desktop.enable = true;
  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.networking.networkmanager.enable = true;

  # enable aarch64-linux emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix = {
    settings = {
      min-free = 53374182400; # ~50GB
      max-free = 107374182400; # 100GB
      cores = 4;
      max-jobs = 8;
    };
  };

  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  #   IdleActionSec=30min
  # '';
}

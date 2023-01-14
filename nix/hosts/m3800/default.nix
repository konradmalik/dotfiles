{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/presets/nixos.nix
      ./../common/optional/wayland-wm.nix
    ];

  networking.hostName = "m3800";

  boot.supportedFilesystems = [ "ntfs" ];

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.networking.wireless.enable = true;

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

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30min
  '';
}

{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./../hardware/m3800.nix
      ./presets/nixos-desktop.nix
      ./modules/nixos-sway.nix
      ./modules/nixos-desktop-apps.nix
    ];

  # lts
  boot.kernelPackages = pkgs.linuxPackages;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

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

  networking.hostName = "m3800";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  #   IdleActionSec=30min
  # '';
}

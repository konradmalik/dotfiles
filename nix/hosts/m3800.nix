{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./../hardware/m3800.nix
      ./presets/nixos.nix
      ./modules/nixos-sway.nix
      ./modules/nixos-desktop-apps.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  nix = {
    settings = {
      min-free = 53374182400; # ~50GB
      max-free = 107374182400; # 100GB
      cores = 2;
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

  ##### disable nvidia
  hardware.nvidiaOptimus.disable = true;
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
  # or run it on-demand
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # hardware.opengl.enable = true;
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   nvidiaBusId = "PCI:0:2:0";
  #   intelBusId = "PCI:2:0:0";
  # };

  services.onedrive.enable = true;

  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  #   IdleActionSec=30min
  # '';
}

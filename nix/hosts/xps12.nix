{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./../hardware/xps12.nix
      ./presets/nixos.nix
    ];

  nix = {
    settings = {
      min-free = 15374182400; # ~15GB
      max-free = 647374182400; # 64GB
      cores = 2;
      max-jobs = 8;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "xps12";

  services.logind.lidSwitch = "ignore";

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
}

{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./../hardware/vaio.nix
      ./presets/nixos-server.nix
      ./modules/sops.nix
    ];

  # lts
  boot.kernelPackages = pkgs.linuxPackages;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 2;
      max-jobs = 8;
    };
  };

  networking.hostName = "vaio";

  # automatically connect with wifi
  sops.secrets.wpa_supplicant_conf = {
    sopsFile = ./../secrets/wpa_supplicant.yaml;
    path = "/etc/wpa_supplicant.conf";
    mode = "0644";
  };

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

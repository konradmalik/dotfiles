{ config, pkgs, lib, username, ... }:
{
  imports =
    [
      ./../hardware/xps12.nix
      ./presets/nixos-server.nix
      ./modules/sops.nix
    ];

  # lts
  boot.kernelPackages = pkgs.linuxPackages;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  nix = {
    settings = {
      min-free = 15374182400; # ~15GB
      max-free = 647374182400; # 64GB
      cores = 2;
      max-jobs = 8;
    };
  };

  networking.hostName = "xps12";

  networking.networkmanager.enable = false;
  networking.wireless.enable = true;

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

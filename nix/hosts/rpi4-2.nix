{ config, pkgs, lib, ... }: {
  imports = [
    ./presets/nixos-headless.nix
  ];

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 2;
      max-jobs = 8;
    };
  };

  networking.networkmanager.enable = false;
  # remember to symlink wpa_supplicant.conf from dotfiles-private
  networking.wireless.enable = true;

  networking.hostName = "rpi4-2";
}

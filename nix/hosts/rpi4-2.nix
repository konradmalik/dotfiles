{ config, pkgs, lib, ... }: {
  imports = [
    ./../hardware/rpi4.nix
    ./presets/nixos-headless.nix
    ./modules/sops.nix
  ];

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 4;
      max-jobs = 8;
    };
  };

  # disable firewall
  networking.firewall.enable = false;

  networking.networkmanager.enable = false;
  networking.wireless.enable = true;

  networking.hostName = "rpi4-2";

  # automatically connect with wifi
  sops.secrets.wpa_supplicant_conf = {
    sopsFile = ./../secrets/wpa_supplicant.yaml;
    path = "/etc/wpa_supplicant.conf";
    mode = "0644";
  };
}

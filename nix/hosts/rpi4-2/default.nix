{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./../common/presets/nixos.nix
  ];

  networking.hostName = "rpi4-2";

  konrad.networking.wireless.enable = true;

  networking.firewall.enable = false;

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 4;
      max-jobs = 8;
    };
  };
}

{ config, pkgs, lib, ... }: {
  imports = [
    ./../hardware/rpi4.nix
    ./presets/nixos-headless.nix
  ];

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 4;
      max-jobs = 8;
    };
  };

  networking.networkmanager.enable = false;
  # remember to symlink wpa_supplicant.conf from dotfiles-private
  networking.wireless.enable = true;

  networking.hostName = "rpi4-1";

  # disable firewall
  networking.firewall.enable = false;

  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      # never spin down all disks, but spin down sda after 300 secs
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a sda -i 300";
    };
  };

  services.shairport-sync = {
    enable = true;
    openFirewall = false;
    arguments = "-v -o alsa";
  };

  # Enable basic sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
  };
}

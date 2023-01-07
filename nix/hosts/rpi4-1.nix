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

  # Enable basic sound
  # only alsa, spotifyd and shairport-sync work best with it
  # however remember that you need to be in "audio" group to work with alsamixer and the rest
  sound.enable = true;

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "alsa";
        bitrate = 320;
        max_cache_size = 5000000000; #5 GB
        initial_volume = "30"; #%
        volume_normalisation = true;
        device_name = "rpi4-1";
        device_type = "speaker";
      };
    };
  };

  # shairport sync requires avahi
  services.shairport-sync = {
    enable = true;
    arguments = "-a rpi4-1 -v -o alsa";
  };

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
  };
}

{ config, pkgs, lib, ... }: {
  imports = [
    ./../hardware/rpi4.nix
    ./presets/nixos-server.nix
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

  networking.hostName = "rpi4-1";

  # automatically connect with wifi
  sops.secrets.wpa_supplicant_conf = {
    sopsFile = ./../secrets/wpa_supplicant.yaml;
    path = "/etc/wpa_supplicant.conf";
    mode = "0644";
  };

  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    environment.SHELL = "/bin/sh";
    serviceConfig = {
      # never spin down all disks, but spin down sda after 300 secs
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a sda -i 300";
      Restart = "always";
      RestartSec = 12;
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

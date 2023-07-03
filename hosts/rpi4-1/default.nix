{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./../common/presets/nixos.nix
  ];

  networking.hostName = "rpi4-1";

  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
  };

  networking.firewall.enable = false;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    syncthing = {
      enable = true;
      user = "konrad";
      bidirectional = false;
    };
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
        use_keyring = false;
        use_mpris = false;
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

{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
    ./../common/modules/blocky.nix
    ./../common/modules/monitoring/agents.nix
  ];

  networking.hostName = "rpi4-1";

  networking.firewall.enable = false;

  services.blocky.enable = true;

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

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "alsa";
        bitrate = 320;
        max_cache_size = 5000000000; # 5 GB
        initial_volume = "50"; # %
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

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  # dhcp
  services.dnsmasq = {
    enable = true;
    # very important, we dont run dns, just dhcp
    resolveLocalQueries = false;
    settings = {
      interface = "end0";
      port = 0;
      dhcp-range = "192.168.100.4,192.168.100.125,255.255.255.0,24h";
      dhcp-option = [
        "option:router,192.168.100.1"
        "option:dns-server,192.168.100.2"
        "option:dns-server,192.168.100.3"
      ];
    };
  };

  # Ensure the network interface has a static IP (required for DHCP server)
  networking = {
    defaultGateway = "192.168.100.1";
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.100.2";
          prefixLength = 24;
        }
      ];
    };
  };
}

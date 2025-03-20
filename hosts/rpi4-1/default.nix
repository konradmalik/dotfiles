{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
    ./../common/modules/blocky.nix
    ./../common/modules/spotifyd.nix
    ./../common/modules/monitoring/agents.nix
  ];

  networking.hostName = "rpi4-1";

  networking.firewall.enable = false;

  services.blocky.enable = true;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    dhcp = {
      enable = true;
      defaultGateway = "192.168.100.1";
      staticIP = "192.168.100.2";
      interface = "end0";
      dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
      dhcp-dns = [
        "192.168.100.2"
        "192.168.100.3"
      ];
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

  services.shairport-sync = {
    enable = true;
    arguments = "-a rpi4-1 -v -o alsa";
    openFirewall = true;
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
}

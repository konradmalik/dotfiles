{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./../common/profiles/rpi4.nix

    ./../common/modules/monitoring/grafana.nix
    ./../common/modules/monitoring/prometheus.nix
  ];

  networking.hostName = "rpi4-2";

  services.blocky.enable = true;

  konrad.services.dhcp =
    let
      ip = "192.168.100.3";
    in
    {
      enable = true;
      defaultGateway = "192.168.100.1";
      staticIP = ip;
      interface = "end0";
      dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
      dhcp-dns = [
        "192.168.100.2"
        ip
      ];
    };

  services.plex = {
    enable = true;
    openFirewall = true;
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

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };
}

{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ./../common/profiles/rpi4.nix

    ./../common/modules/monitoring/grafana.nix
    ./../common/modules/monitoring/prometheus.nix
  ];

  networking.hostName = "rpi4-2";

  services.blocky.enable = true;

  sops.secrets.healthcheck.key = "healthchecks/rpi4-2";
  konrad.services.healthcheck.urlFile = config.sops.secrets.healthcheck.path;

  networking = {
    defaultGateway = "192.168.100.1";
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.100.3";
          prefixLength = 24;
        }
      ];
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  konrad.services.hd-idle.enable = true;

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };
}

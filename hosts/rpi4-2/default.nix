{ config, ... }:
{
  imports = [
    ./hardware.nix

    ../../system/profiles/rpi4.nix

    ../../system/modules/monitoring/grafana.nix
    ../../system/modules/monitoring/prometheus.nix
  ];

  home-manager.users.konrad.imports = [ ./home.nix ];

  networking = {
    hostName = "rpi4-2";
    # dhcp is served by the router; we just need a stable address for blocky
    defaultGateway = "192.168.88.1";
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.88.3";
          prefixLength = 24;
        }
      ];
    };
  };

  services.blocky.enable = true;

  sops.secrets.healthcheck.key = "healthchecks/rpi4-2";
  konrad.services.healthcheck.urlFile = config.sops.secrets.healthcheck.path;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  konrad.services.hd-idle.enable = true;

  fileSystems = {
    "/mnt" = {
      device = "/dev/disk/by-uuid/37d6273c-f954-442c-9c0d-3ee305898fd9";
      fsType = "ext4";
      options = [
        "nofail"
        "noatime"
      ];
    };
  };
}

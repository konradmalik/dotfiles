{ config, ... }:
{
  imports = [
    ../../system/profiles/rpi4.nix
  ];

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

  # odd/even days so both DNS resolvers never reboot together
  konrad.services.autoupgrade.dates = "*-*-2/2 02:00";

  sops.secrets.healthcheck.key = "healthchecks/rpi4-2";
  konrad.services.healthcheck.urlFile = config.sops.secrets.healthcheck.path;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
  };
  # library lives on the external disk; don't start against an empty /mnt
  systemd.services.audiobookshelf.unitConfig.RequiresMountsFor = [ "/mnt" ];

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

{ config, ... }:
{
  imports = [
    ../../system/profiles/rpi4.nix
    ../../system/modules/beszel-agent.nix
    ../../system/modules/beszel-hub.nix
  ];

  networking = {
    hostName = "rpi4-1";
    # dhcp is served by the router; we just need a stable address for blocky
    defaultGateway = "192.168.88.1";
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.88.2";
          prefixLength = 24;
        }
      ];
    };
  };

  services.blocky.enable = true;

  services.beszel.agent.smartmon.enable = true;

  # odd/even days so both DNS resolvers never reboot together
  konrad.services.autoupgrade.dates = "*-*-1/2 02:00";

  sops.secrets.healthcheck.key = "healthchecks/rpi4-1";
  konrad.services.healthcheck.urlFile = config.sops.secrets.healthcheck.path;

  fileSystems."/mnt" = {
    device = "/dev/disk/by-uuid/ea8a0e2d-7ed1-4de7-bd7e-6ffacfba02d8";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
    ];
  };
}

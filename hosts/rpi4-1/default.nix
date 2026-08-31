{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../common/profiles/rpi4.nix
  ];

  networking.hostName = "rpi4-1";

  services.blocky.enable = true;

  sops.secrets.healthcheck.key = "healthchecks/rpi4-1";
  konrad.services.healthcheck.urlFile = config.sops.secrets.healthcheck.path;

  networking = {
    defaultGateway = "192.168.100.1";
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

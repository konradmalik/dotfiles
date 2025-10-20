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

  konrad.services = {
    dhcp =
      let
        ip = "192.168.100.2";
      in
      {
        enable = true;
        defaultGateway = "192.168.100.1";
        staticIP = ip;
        interface = "end0";
        dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
        dhcp-dns = [
          ip
          "192.168.100.3"
        ];
      };
  };
}

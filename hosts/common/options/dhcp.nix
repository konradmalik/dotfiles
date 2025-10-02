{
  config,
  lib,
  ...
}:
let
  cfg = config.konrad.services.dhcp;
in
{
  options.konrad.services.dhcp = {
    enable = lib.mkEnableOption "Enables dhcp server";

    defaultGateway = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1";
      description = "IP of the default gateway (router)";
    };

    staticIP = lib.mkOption {
      type = lib.types.str;
      example = "192.168.1.1";
      description = "static IP to set to this dhcp server";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      example = "eth0";
      description = "interface to use for dhcp";
    };

    dhcp-range = lib.mkOption {
      type = lib.types.str;
      example = "192.168.100.1,192.168.100.254,255.255.255.0,24h";
      description = "dhcp range in dnsmasq format";
    };

    dhcp-dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = ''[ "8.8.8.8" "8.4.4.8" ]'';
      description = "dns servers advertised by this dhcp server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      # very important, we dont run dns, just dhcp
      resolveLocalQueries = false;
      settings = {
        inherit (cfg) dhcp-range interface;
        # disable dns
        port = 0;
        dhcp-option = [
          "option:router,${cfg.defaultGateway}"
          "option:dns-server,${lib.concatStringsSep "," cfg.dhcp-dns}"
        ];
      };
    };

    # Ensure the network interface has a static IP (required for DHCP server)
    networking = {
      inherit (cfg) defaultGateway;
      interfaces.end0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = cfg.staticIP;
            prefixLength = 24;
          }
        ];
      };
    };

    networking.firewall = {
      allowedUDPPorts = [ 67 ];
    };
  };
}

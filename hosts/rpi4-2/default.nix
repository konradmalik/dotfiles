{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
    ./../common/modules/blocky.nix
    ./../common/modules/monitoring/agents.nix
    ./../common/modules/monitoring/grafana.nix
    ./../common/modules/monitoring/prometheus.nix
  ];

  networking.hostName = "rpi4-2";

  services.blocky.enable = true;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    dhcp = {
      enable = true;
      defaultGateway = "192.168.100.1";
      staticIP = config.konrad.homelab.rpi4-2.localIP;
      interface = "end0";
      dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
      dhcp-dns = [
        config.konrad.homelab.rpi4-1.localIP
        config.konrad.homelab.rpi4-2.localIP
      ];
    };
    syncthing = {
      enable = true;
      user = "konrad";
      bidirectional = false;
    };
  };
}

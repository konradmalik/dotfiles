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

  networking.firewall.enable = false;

  services.blocky.enable = true;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    dhcp = {
      enable = true;
      defaultGateway = "192.168.100.1";
      staticIP = "192.168.100.3";
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
}

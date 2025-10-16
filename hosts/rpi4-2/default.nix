{
  imports = [
    ./hardware-configuration.nix

    ./../common/profiles/rpi4.nix

    ./../common/modules/monitoring/grafana.nix
    ./../common/modules/monitoring/prometheus.nix
  ];

  networking.hostName = "rpi4-2";

  services.blocky.enable = true;

  sops.secrets.healthcheck = {
    key = "healthchecks/rpi4-2";
  };

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

  konrad.services.hd-idle.enable = true;

  fileSystems = {
    "/mnt" = {
      device = "/dev/sda2";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };
}

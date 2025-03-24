{ config, lib, ... }:
let
  mkTargets = ip: [
    # node-exporter
    "${ip}:${toString config.services.prometheus.exporters.node.port}"
    # systemd-exporter
    "${ip}:${toString config.services.prometheus.exporters.systemd.port}"
    # blocky
    "${ip}:${toString config.services.blocky.settings.ports.http}"
  ];

in
{
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    port = 9090;
    scrapeConfigs = [
      {
        job_name = "rpi4-1";
        static_configs = [
          {
            targets = mkTargets "192.168.100.2";
          }
        ];
      }
      {
        job_name = "rpi4-2";
        static_configs = [
          {
            targets = mkTargets "192.168.100.3";
          }
        ];
      }
    ];
  };
  networking.firewall = {
    allowedTCPPorts = lib.optional config.services.prometheus.enable config.services.prometheus.port;
  };
}

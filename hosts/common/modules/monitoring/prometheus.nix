{ config, lib, ... }:
{
  services.prometheus = {
    enable = true;
    retentionTime = "15d";
    port = 9090;
    scrapeConfigs = [
      {
        job_name = config.networking.hostName;
        static_configs = [
          {
            targets = [
              # node-exporter
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              # systemd-exporter
              "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
              # blocky
              "127.0.0.1:${toString config.services.blocky.settings.ports.http}"
            ];
          }
        ];
      }
      {
        job_name = "rpi4-1";
        static_configs = [
          (
            let
              ip = "192.168.100.2";
            in
            {
              targets = [
                # node-exporter
                "${ip}:${toString config.services.prometheus.exporters.node.port}"
                # systemd-exporter
                "${ip}:${toString config.services.prometheus.exporters.systemd.port}"
                # blocky
                "${ip}:${toString config.services.blocky.settings.ports.http}"
                # blocky
                "${ip}:${toString config.services.blocky.settings.ports.http}"
              ];
            }
          )
        ];
      }
    ];
  };
  networking.firewall = {
    allowedTCPPorts = lib.optional config.services.prometheus.enable config.services.prometheus.port;
  };
}

{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../common/modules/blocky.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "rpi4-2";

  networking.firewall.enable = false;

  services.blocky.enable = true;

  konrad.services = {
    autoupgrade = {
      enable = true;
    };
    syncthing = {
      enable = true;
      user = "konrad";
      bidirectional = false;
    };
  };

  # monitoring stack
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "100.78.182.5";
        http_port = 3000;
      };
      panels = {
        # allows raw html and scripts in panels
        disable_sanitize_html = true;
      };
    };
    provision = {
      enable = true;
      datasources = {
        settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
            }
          ];
        };
      };
    };
  };

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
              ip = "192.168.68.55";
            in
            {
              targets = [
                # node-exporter
                "${ip}:${toString config.services.prometheus.exporters.node.port}"
                # systemd-exporter
                "${ip}:${toString config.services.prometheus.exporters.systemd.port}"
                # blocky
                "${ip}:${toString config.services.blocky.settings.ports.http}"
              ];
            }
          )
        ];
      }
    ];
  };

  # monitoring agents
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
      systemd = {
        enable = true;
        port = 9558;
      };
    };
  };
}

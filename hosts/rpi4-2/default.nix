{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../common/nixos.nix
    ./../common/modules/blocky.nix
    ./../common/modules/unbound.nix
    ./../common/modules/monitoring/agents.nix
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
              # unbound
              "127.0.0.1:${toString config.services.prometheus.exporters.unbound.port}"
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
                # unbound
                "${ip}:${toString config.services.prometheus.exporters.unbound.port}"
              ];
            }
          )
        ];
      }
    ];
  };

  # dhcp
  services.dnsmasq = {
    enable = true;
    # very important, we dont run dns, just dhcp
    resolveLocalQueries = false;
    settings = {
      interface = "end0";
      port = 0;
      dhcp-range = "192.168.100.126,192.168.100.254,255.255.255.0,24h";
      dhcp-option = [
        "option:router,192.168.100.1"
        "option:dns-server,192.168.100.2,192.168.100.3"
      ];
    };
  };

  # Ensure the network interface has a static IP (required for DHCP server)
  networking = {
    defaultGateway = "192.168.100.1";
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
    interfaces.end0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.100.3";
          prefixLength = 24;
        }
      ];
    };
  };
}

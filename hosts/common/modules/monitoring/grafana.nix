{ config, lib, ... }:
{
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
  networking.firewall = {
    allowedTCPPorts = lib.optional config.services.grafana.enable config.services.grafana.settings.server.http_port;
  };
}

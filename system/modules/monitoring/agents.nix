{
  services.blocky.settings.prometheus.enable = true;

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
        openFirewall = true;
      };
      systemd = {
        enable = true;
        port = 9558;
        openFirewall = true;
      };
    };
  };
}

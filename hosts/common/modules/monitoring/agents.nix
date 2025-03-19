{
  services.blocky.settings.prometheus.enable = true;

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

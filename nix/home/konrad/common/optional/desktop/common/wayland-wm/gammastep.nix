{
  services.gammastep = {
    enable = true;
    enableVerboseLogging = true;
    tray = false;
    provider = "geoclue2";
    temperature = {
      day = 6000;
      night = 4600;
    };
    settings = {
      general.adjustment-method = "wayland";
    };
  };

  services.wlsunset = {
    enable = false;
    systemdTarget = "graphical-session.target";
    latitude = "52.2";
    longitude = "21.0";
  };
}

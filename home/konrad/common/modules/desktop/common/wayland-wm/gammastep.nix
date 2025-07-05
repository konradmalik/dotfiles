{ osConfig, ... }:
{
  assertions = [
    {
      assertion = osConfig.services.geoclue2.enable;
      message = "geoclue2 must be enabled globally to use it in gammastep";
    }
  ];

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 6000;
      night = 4600;
    };
    settings = {
      general.adjustment-method = "wayland";
      wayland.output = "*";
    };
  };
}

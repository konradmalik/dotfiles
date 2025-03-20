{ config, lib, ... }:
{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "alsa";
        bitrate = 320;
        max_cache_size = 5000000000; # 5 GB
        initial_volume = 50; # %
        volume_normalisation = true;
        device_name = "rpi4-1";
        device_type = "speaker";
        use_keyring = false;
        use_mpris = false;
        zeroconf_port = 42449;
      };
    };
  };
  networking.firewall = {
    allowedTCPPorts = lib.optional config.services.spotifyd.enable config.services.spotifyd.settings.global.zeroconf_port;
    allowedUDPPorts = lib.optional config.services.spotifyd.enable 5353;
  };
}

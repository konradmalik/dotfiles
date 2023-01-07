{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  # those must be user services
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pulseaudio";
        bitrate = 320;
        max_cache_size = 5000000000; #5 GB
        initial_volume = "30"; #%
        volume_normalisation = true;
        device_name = "rpi4-1";
        device_type = "speaker";
      };
    };
  };
}

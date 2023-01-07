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
  # and user needs to be in "audio" group, make sure of that
  # because those are user services, they start only after a user logs in!
  # and will be killed after the user logs out, but we can simply run tmux on rpi4-1 so it will keep those services running
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

  systemd.user.services.shairport-sync = {
    Unit = {
      Description = "shairport-sync daemon";
      Documentation = "https://github.com/mikebrady/shairport-sync";
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${pkgs.shairport-sync}/bin/shairport-sync -v -o pa";
      Restart = "always";
      RestartSec = 12;
    };
  };
}

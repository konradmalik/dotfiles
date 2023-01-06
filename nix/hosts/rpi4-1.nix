{ config, pkgs, lib, ... }: {
  imports = [
    ./presets/nixos-headless.nix
  ];

  nix = {
    settings = {
      min-free = 10374182400; # ~10GB
      max-free = 327374182400; # 32GB
      cores = 2;
      max-jobs = 8;
    };
  };

  networking.networkmanager.enable = false;
  # remember to symlink wpa_supplicant.conf from dotfiles-private
  networking.wireless.enable = true;

  networking.hostName = "rpi4-1";

  systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 -a sdb -i 600";
    };
  };

  services.shairport-sync = {
    enable = true;
    openFirewall = false;
    #arguments = "";
  };

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        bitrate = 320;
        max_cache_size = 5000000000; #5 GB
        initial_volume = "30"; #%
      };
    };
  };
}

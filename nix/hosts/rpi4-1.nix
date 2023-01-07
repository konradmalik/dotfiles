{ config, pkgs, lib, ... }: {
  imports = [
    ./../hardware/rpi4.nix
    ./presets/nixos-headless.nix
  ];

  # TODO make importable
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    consoleLogLevel = lib.mkDefault 7;

    # The serial ports listed here are:
    # - ttyS0: for Tegra (Jetson TX1)
    # - ttyAMA0: for QEMU's -machine virt
    kernelParams =
      [ "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0" ];

    initrd.availableKernelModules = [
      # Allows early (earlier) modesetting for the Raspberry Pi
      "vc4"
      "bcm2835_dma"
      "i2c_bcm2835"
      # Allows early (earlier) modesetting for Allwinner SoCs
      "sun4i_drm"
      "sun8i_drm_hdmi"
      "sun8i_mixer"
    ];
  };

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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
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
        volume_normalisation = true;
        device_name = config.networking.hostName;
        device_type = "speaker";
      };
    };
  };
}

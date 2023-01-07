{ pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

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

}

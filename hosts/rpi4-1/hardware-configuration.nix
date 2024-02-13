{
  imports = [
    ../common/hardware/rpi4.nix
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024;
  }];
}

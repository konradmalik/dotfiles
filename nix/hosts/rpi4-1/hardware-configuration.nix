{ pkgs, lib, modulesPath, ... }: {
  imports = [
    ../common/hardware/rpi4.nix
  ];

  hardware.raspberry-pi."4".audio.enable = true;
}

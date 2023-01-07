{ pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  hardware.raspberry-pi."4".audio.enable = true;
}

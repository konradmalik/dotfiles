{ pkgs, lib, modulesPath, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  hardware.raspberry-pi."4".audio.enable = true;
}

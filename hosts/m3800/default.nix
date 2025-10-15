{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ./hardware-configuration.nix
    ./disko.nix

    ../common/profiles/desktop.nix
  ];

  networking.hostName = "m3800";
}

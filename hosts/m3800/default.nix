{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

    ./hardware-configuration.nix
    ./disko.nix

    ../common/profiles/laptop.nix
  ];

  networking.hostName = "m3800";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # as long as scale in hyprland is 2, this makes sense
  stylix.cursor.size = 16;
}

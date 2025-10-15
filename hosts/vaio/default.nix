{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disko.nix

    ../common/profiles/server.nix
  ];

  networking.hostName = "vaio";

  # avoid overheat
  nix.settings = {
    cores = 2;
    max-jobs = 4;
  };
}

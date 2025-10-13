{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./disko.nix

    ./../common/nixos.nix
  ];

  networking.hostName = "vaio";

  konrad.network.wireless.enable = true;

  konrad.services.autoupgrade = {
    enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # avoid overheat
  nix.settings = {
    cores = 2;
    max-jobs = 4;
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
}

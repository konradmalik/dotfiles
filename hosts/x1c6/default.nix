{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen

    ./hardware-configuration.nix
    ./disko.nix

    ../common/profiles/laptop.nix
  ];

  networking.hostName = "x1c6";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };
}

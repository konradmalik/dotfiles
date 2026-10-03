{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen

    ./hardware.nix
    ./disko.nix

    ../../system/profiles/laptop.nix
  ];

  home-manager.users.konrad.imports = [ ./home.nix ];

  networking.hostName = "x1c6";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 70;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };
}

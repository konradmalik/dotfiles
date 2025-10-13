{ inputs, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

    ./hardware-configuration.nix
    ./disko.nix

    ./../common/modules/hyprland.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "framework";

  boot = {
    tmp = {
      cleanOnBoot = false;
      useTmpfs = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.network.wireless.enable = true;
  konrad.services = {
    autoupgrade = {
      enable = true;
      allowReboot = false;
      operation = "boot";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.settings.Login = {
    SleepOperation = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "30min";
  };
}

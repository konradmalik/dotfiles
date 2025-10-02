{
  imports = [
    ./hardware-configuration.nix
    ./../common/modules/hyprland.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "m3800";

  boot.supportedFilesystems = [ "ntfs" ];

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
    IdleAction = "suspend";
    IdleActionSec = "30min";
    LidSwitch = "suspend";
    LidSwitchDocked = "ignore";
  };
}

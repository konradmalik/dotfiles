{
  imports = [
    ../modules/hyprland.nix

    ../systems/nixos.nix
  ];

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
    LidSwitch = "suspend";
    LidSwitchDocked = "ignore";
  };
}

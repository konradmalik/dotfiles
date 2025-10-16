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

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
    IdleAction = "suspend";
    IdleActionSec =
      let
        minutes = 30;
      in
      "${toString (60 * minutes)}";
  };
}

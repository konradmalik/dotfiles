{
  imports = [
    ../../modules/hyprland.nix

    ../../systems/nixos.nix
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
    # NOTE: idle does not seem to work when using hypridle, so define it there instead
  };
}

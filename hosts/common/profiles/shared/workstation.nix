{ pkgs, ... }:
{
  imports = [
    ../../modules/hyprland.nix
    ../../modules/fontconfig.nix

    ../../systems/nixos.nix
  ];

  environment.systemPackages = with pkgs; [ bashmount ];

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.network.wireless.enable = true;
  konrad.services = {
    autoupgrade = {
      enable = true;
      allowReboot = false;
      operation = "boot";
    };

    syncthing = {
      enable = true;
      bidirectional = true;
    };
  };

  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
    # NOTE: idle does not seem to work when using hypridle, so define it there instead
  };

  # start ssh-agent per user to remember ssh private keys
  programs.ssh = {
    startAgent = true;
    agentTimeout = null;
    askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    enableAskPassword = true;
  };
}

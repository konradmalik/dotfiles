{ pkgs, ... }:
{
  imports = [
    ../modules/dm.nix
    ../modules/hyprland.nix
    ../modules/fontconfig.nix
    ../modules/printing.nix

    ../systems/nixos.nix
  ];

  environment.systemPackages = with pkgs; [ bashmount ];

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;

  # TODO fill them
  # sops.secrets."wifi/home" = { };
  # sops.secrets."wifi/office" = { };
  konrad.network.wireless = {
    enable = true;
    networks = {
      # "home".passphraseFile = config.sops.secrets."wifi/home".path;
      # "office wifi".passphraseFile = config.sops.secrets."wifi/office".path;
      "some cafe".passphrase = "freecoffee";
    };
  };

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

  programs.localsend.enable = true;

  # start ssh-agent per user to remember ssh private keys
  programs.ssh = {
    startAgent = true;
    agentTimeout = null;
    askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    enableAskPassword = true;
  };
}

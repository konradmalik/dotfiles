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

  konrad.network.wireless = {
    enable = true;
    networks = {
      home = {
        ssid = "pozdrawiamhipstera";
        passphraseSecret = "wifi/home";
      };
      hotspot = {
        ssid = "Konrad’s iPhone";
        passphraseSecret = "wifi/hotspot";
      };
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

  # required for tpm-sealed ssh keys, see home-manager's services.ssh-tpm-agent
  security.tpm2.enable = true;

  # the agents themselves are started by home-manager (services.ssh-agent and
  # services.ssh-tpm-agent), here we only provide askpass for non-tpm keys
  programs.ssh = {
    askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    enableAskPassword = true;
  };
}

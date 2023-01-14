{ config, lib, pkgs, inputs, ... }:
with lib;
let cfg = config.konrad.networking.wireless;
in
{
  options.konrad.networking.wireless = {
    enable = mkEnableOption "Enables wireless with wpa_supplicant via sops-nix";
  };

  config = mkIf cfg.enable {

    networking.networkmanager.enable = false;

    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    sops.secrets."wireless.env" = {
      mode = "0644";
    };

    networking.wireless = {
      enable = true;
      # Declarative
      environmentFile = config.sops.secrets."wireless.env".path;
      networks = {
        "UPC7335283".psk = "@PSK_UPC7335283@";
        "UPC8795410".psk = "@PSK_UPC8795410@";
        "MALIK_E_DOM".psk = "@PSK_MALIK_E_DOM";
        "TP-LINK_FD1F".psk = "@PSK_TP_LINK_FD1F";
        "Konrad's iPhone".psk = "@PSK_KONRADS_IPHONE";
      };
      # Imperative
      allowAuxiliaryImperativeNetworks = true;
      userControlled = {
        enable = true;
        group = "network";
      };
      extraConfig = ''
        update_config=1
      '';
    };

    # since we enabled Imperative, we need to make sure /etc/wpa_supplicant.conf exists
    system.activationScripts = {
      wpa_supplicant_conf.text =
        ''
          touch -a /etc/wpa_supplicant.conf
        '';
    };

    # Ensure group exists
    users.groups.network = { };
  };
}

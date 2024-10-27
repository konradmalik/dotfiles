{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.networking.wireless;
in
{
  options.konrad.networking.wireless = {
    enable = mkEnableOption "Enables wireless with wpa_supplicant via sops-nix";
    interfaces = mkOption {
      type = types.listOf types.str;
      example = ''[ "wlp2s0" ]'';
      description = "Interfaces to manage. If not specified - wpa_supplicant can fail on boot and not restart.";
    };
  };

  config = mkIf cfg.enable {

    networking.networkmanager.enable = false;

    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    sops.secrets."wireless.conf" = {
      mode = "0644";
    };

    networking.wireless = {
      enable = true;
      # Declarative
      secretsFile = config.sops.secrets."wireless.conf".path;
      networks = {
        "pozdrawiamhipstera".pskRaw = "ext:psk_pozdrawiamhipstera";
        "UPC7335283".pskRaw = "ext:psk_UPC7335283";
        "UPC8795410".pskRaw = "ext:psk_UPC8795410";
        "MALIK_E_DOM".pskRaw = "ext:psk_MALIK_E_DOM";
        "TP-LINK_FD1F".pskRaw = "ext:psk_TP_LINK_FD1F";
        "Konrad's iPhone".pskRaw = "ext:psk_KONRADS_IPHONE";
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
      wpa_supplicant_conf.text = ''
        touch -a /etc/wpa_supplicant.conf
      '';
    };

    # Ensure group exists
    users.groups.network = { };
  };
}

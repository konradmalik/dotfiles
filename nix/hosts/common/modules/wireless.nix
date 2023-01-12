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

    sops.secrets."wireless.env" = {
      mode = "0644";
    };

    networking.wireless.environmentFile = config.sops.secrets."wireless.env".path;

    networking.wireless = {
      enable = true;
      networks = {
        "UPC7335283".psk = "@PSK_UPC7335283@";
        "UPC8795410".psk = "@PSK_UPC8795410@";
        "MALIK_E_DOM".psk = "@PSK_MALIK_E_DOM";
      };
    };
  };
}

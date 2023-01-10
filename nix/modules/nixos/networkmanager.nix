{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.networking.networkmanager;
in
{
  options.konrad.networking.networkmanager = {
    enable = mkEnableOption "Enables network manager with cloudflare dns";
  };

  config = mkIf cfg.enable {
    networking.networkmanager = {
      enable = true;
      insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
    };
    networking.wireless.enable = false;
  };
}

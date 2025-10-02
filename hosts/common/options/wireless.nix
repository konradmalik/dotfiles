{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.network.wireless;
in
{
  options.konrad.network.wireless = {
    enable = mkEnableOption "Enables custom network config";
  };

  config = mkIf cfg.enable {
    services.resolved.enable = true;
    networking = {
      networkmanager.enable = true;
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };
}

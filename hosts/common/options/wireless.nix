{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.network.wireless;
in
{
  options.konrad.network.wireless = {
    enable = mkEnableOption "Enables custom network config";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      impala
    ];

    services.resolved.enable = true;
    networking = {
      wireless.iwd = {
        enable = true;
        settings = {
          Settings.AutoConnect = true;

          Network = {
            EnableIPv6 = false;
          };
        };
      };
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };
  };
}

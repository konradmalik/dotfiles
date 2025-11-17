{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.hardware.bluetooth;
in
{
  options.konrad.hardware.bluetooth = {
    enable = mkEnableOption "Enables the bluetooth with keychron fixes";

    powerOnBoot = mkOption {
      type = lib.types.bool;
      default = true;
      description = "powerOnBoot";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.bluez;
      defaultText = "pkgs.bluez";
      description = "package to install";
    };
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      powerOnBoot = cfg.powerOnBoot;
      # settings for keychron
      settings = {
        General = {
          FastConnectable = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      bluetui
    ];
  };
}

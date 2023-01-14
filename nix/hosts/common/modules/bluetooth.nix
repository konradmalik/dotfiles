{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.hardware.bluetooth;
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
      default = pkgs.bluezFull;
      defaultText = "pkgs.bluezFull";
      description = "package to install";
    };
  };

  config = mkIf cfg.enable {

    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      powerOnBoot = cfg.powerOnBoot;
      # settings for keychron
      settings = {
        General = {
          FastConnectable = true;
          ReconnectAttempts = 5;
          ReconnectIntervals = "1, 2, 3";
        };
      };
    };

    environment. systemPackages = with pkgs; [
      bluez-tools # for bluetoothctl and other stuff
    ];
  };
}

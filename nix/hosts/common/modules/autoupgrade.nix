{ pkgs, lib, config, ... }:
let
  cfg = config.konrad.services.autoupgrade;
in
{
  options.konrad.services.autoupgrade = {
    enable = lib.mkEnableOption "Whether to enable autoupgrade from Github flake";
    persistent = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "whether to run if missed when the system was powered down";
    };
    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether to allow reboot if kernel and related were updated";
    };
    operation = lib.mkOption {
      type = lib.types.enum [ "switch" "boot" ];
      example = "switch";
      default = "switch";
      description = "switch or boot mode of nixos-rebuild";
    };
    flakeUrl = lib.mkOption {
      type = lib.types.str;
      example = "github:konradmalik/dotfiles";
      default = "github:konradmalik/dotfiles";
      description = "url of the flake (without the #.. part)";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
      example = "m3800";
      description = "machine hostname target to update. will be used in #.. after the flake url";
    };
    dates = lib.mkOption {
      type = lib.types.str;
      example = "22:00";
      default = "22:00";
      description = "systemd timer when to run upgrade";
    };
    rebootWindowLower = lib.mkOption {
      type = lib.types.str;
      example = "01:00";
      default = "01:00";
      description = "lower bound on allowed reboot. Used only if allowReboot is true";
    };
    rebootWindowUpper = lib.mkOption {
      type = lib.types.str;
      example = "06:00";
      default = "06:00";
      description = "upper bound on allowed reboot. Used only if allowReboot is true";
    };
  };
  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      persistent = cfg.persistent;
      operation = cfg.operation;
      flake = "${cfg.flakeUrl}#${cfg.hostname}";
      dates = cfg.dates;
      allowReboot = cfg.allowReboot;
      rebootWindow = {
        lower = cfg.rebootWindowLower;
        upper = cfg.rebootWindowUpper;
      };
    };
  };
}

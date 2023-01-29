{ pkgs, lib, config, ... }:
let
  cfg = config.services.vbetool;
in
{
  options.services.vbetool = {
    enable = lib.mkEnableOption "Whether to enable vbetool service (disabling screen from tty)";
    timeAfterBoot = lib.mkOption {
      type = lib.types.str;
      example = "15min";
      description = "Time after boot when to run the service. Systemd timer format.";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.vbetool = {
      description = "automatic monitor shutdown after boot";
      script = "${pkgs.vbetool}/bin/vbetool dpms off";
    };
    systemd.timers.vbetool = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "${cfg.timeAfterBoot}";
      };
    };
  };
}

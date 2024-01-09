{ config, pkgs, lib, ... }:
let
  cfg = config.services.rtcwake;
in
{
  options.services.rtcwake = {
    enable = lib.mkEnableOption "Whether to enable rtcwake service";
    on = lib.mkOption {
      type = lib.types.str;
      example = "tomorrow 08:00";
      description = "Time (UTC) when to power on. Should be format specified to '-d' flag to 'date' command.";
    };
    off = lib.mkOption {
      type = lib.types.str;
      example = "*-*-* 23:00:00";
      description = "Time (UTC) when to power off (according to 'mode'). Should be systemd OnCalendar format.";
    };
    mode = lib.mkOption {
      type = lib.types.enum [ "off" "on" "sleep" "mem" "disk" "standby" "freeze" ];
      example = "mem";
      description = "rtcwake mode to use";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.rtcwake = {
      description = "automatic shutdown and boot after some time";
      script = "${pkgs.util-linux}/bin/rtcwake --mode ${cfg.mode} --utc --time $(date +%s --utc -d '${cfg.on}')";
    };
    systemd.timers.rtcwake = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "${cfg.off} UTC";
      };
    };
  };
}

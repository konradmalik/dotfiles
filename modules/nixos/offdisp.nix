{ lib, config, ... }:
let
  cfg = config.services.offdisp;
in
{
  options.services.offdisp = {
    enable = lib.mkEnableOption "Whether to enable offdisp service (disabling screen from tty)";
    timeAfterBoot = lib.mkOption {
      type = lib.types.str;
      example = "15min";
      description = "Time after boot when to run the service. Systemd timer format.";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.offdisp = {
      description = "automatic monitor shutdown after boot";
      script = ''
        bl_power="/sys/class/backlight/intel_backlight/bl_power"
        if [[ $(cat $bl_power) = 0 ]]; then
          echo "disabling"
          echo 1 > $bl_power
        else
          echo "enabling"
          echo 0 > $bl_power
        fi
      '';
    };
    systemd.timers.offdisp = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "${cfg.timeAfterBoot}";
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.konrad.services.hd-idle;
in
{
  options.konrad.services.hd-idle = {
    enable = lib.mkEnableOption "Enables a service to spin down disks after idle time";

    disks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      example = "[ \"/dev/sda\" ]";
      default = [ ];
      description = "Disks to spin down. Set this to empty list to spin down all external disks.";
    };

    idleTime = lib.mkOption {
      type = lib.types.int;
      example = "300";
      default = 300;
      description = "Idle time in secs until spindown";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hd-idle = {
      description = "External HD spin down daemon";
      wantedBy = [ "multi-user.target" ];
      environment.SHELL = "/bin/sh";
      serviceConfig = {
        ExecStart =
          if (builtins.length cfg.disks) == 0 then
            "${pkgs.hd-idle}/bin/hd-idle -i ${toString cfg.idleTime}"
          else
            let
              args = lib.concatStringsSep "" (
                builtins.concatMap (d: [ " -a ${d} -i ${toString cfg.idleTime}" ]) cfg.disks
              );
            in
            "${pkgs.hd-idle}/bin/hd-idle -i 0 ${args}";
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}

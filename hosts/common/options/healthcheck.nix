{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.konrad.services.healthcheck;
in
{
  options.konrad.services.healthcheck = {
    enable = lib.mkEnableOption "Healthchecks.io ping service";

    urlFile = lib.mkOption {
      type = lib.types.path;
      example = "/tmp/url.txt";
      description = "Path to the Healthchecks.io URL in a file";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      example = "10min";
      description = "How often to ping the Healthchecks.io endpoint.";
    };

    curlPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.curl;
      description = "Curl package to use for sending pings.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.healthcheck = {
      description = "Ping Healthchecks.io endpoint";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.curlPackage}/bin/curl --fail --silent --show-error --max-time 10 --retry 5 $(<${cfg.urlFile})";
      };
    };

    systemd.timers.healthcheck = {
      description = "Timer to periodically ping Healthchecks.io";
      wantedBy = [ "timers.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.interval;
        Unit = "healthcheck.service";
      };
    };
  };
}

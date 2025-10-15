{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.konrad.services.ntfy;
in
{
  options.konrad.services.ntfy = {
    enable = lib.mkEnableOption "Enables ntfy services";

    server = lib.mkOption {
      type = lib.types.str;
      example = "https://ntfy.example.sh";
      default = "https://ntfy.sh";
      description = "server to use";
    };

    problemServiceName = lib.mkOption {
      type = lib.types.str;
      default = "notify-problem";
      readOnly = true;
      description = "Name of the created systemd service for problems, without @";
    };

    infoServiceName = lib.mkOption {
      type = lib.types.str;
      default = "info";
      readOnly = true;
      description = "Name of the created systemd service for information, without @";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "ntfy/topic/problem" = { };
      "ntfy/topic/info" = { };
      "ntfy/token" = { };
    };

    systemd.services = {
      "${cfg.problemServiceName}@" = {
        enable = true;
        environment.SERVICE = "%i";
        script = ''
          NTFY_TOKEN="$(cat ${config.sops.secrets."ntfy/token".path})"
          ${pkgs.curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
            -H "Authorization: Bearer $NTFY_TOKEN" \
            -H "Title: [$(${pkgs.inetutils}/bin/hostname)] $SERVICE status" \
            -H "tags:warning" \
            -H "prio:high" \
            -d "Failed!" \
            ${cfg.server}/$(<${config.sops.secrets."ntfy/topic/problem".path})
        '';
      };
      "${cfg.infoServiceName}@" = {
        enable = true;
        environment.SERVICE = "%i";
        script = ''
          NTFY_TOKEN="$(cat ${config.sops.secrets."ntfy/token".path})"
          ${pkgs.curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
            -H "Authorization: Bearer $NTFY_TOKEN" \
            -H "Title: [$(${pkgs.inetutils}/bin/hostname)] $SERVICE status" \
            -H "prio:min" \
            -d "Succeeded." \
            ${cfg.server}/$(<${config.sops.secrets."ntfy/topic/info".path})
        '';
      };
    };
  };
}

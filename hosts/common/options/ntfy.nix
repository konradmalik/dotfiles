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

    systemd.services =
      let
        ntfyTokenFile = config.sops.secrets."ntfy/token".path;
        ntfyErrorTopicFile = config.sops.secrets."ntfy/topic/problem".path;
        ntfyInfoTopicFile = config.sops.secrets."ntfy/topic/info".path;

        notifierError = pkgs.callPackage ../../../pkgs/special/ntfy-sender.nix {
          inherit ntfyTokenFile;
          ntfyHost = cfg.server;
          ntfyTopicFile = ntfyErrorTopicFile;
          priority = "high";
          tags = "warning";
          title = "$SERVICE status";
          text = "failed";
        };

        notifierInfo = pkgs.callPackage ../../../pkgs/special/ntfy-sender.nix {
          inherit ntfyTokenFile;
          ntfyHost = cfg.server;
          ntfyTopicFile = ntfyInfoTopicFile;
          priority = "min";
          title = "$SERVICE status";
          text = "succeeded";
        };
      in
      {
        "${cfg.problemServiceName}@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = "${notifierError}";
        };
        "${cfg.infoServiceName}@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = "${notifierInfo}";
        };
      };
  };
}

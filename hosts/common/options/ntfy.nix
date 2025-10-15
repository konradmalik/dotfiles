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
      "ntfy/topic" = { };
      "ntfy/token" = { };
    };

    systemd.services =
      let
        notifierError = pkgs.callPackage ../../../pkgs/special/ntfy-sender.nix {
          inherit config;
          priority = "high";
          tags = "warning";
          title = "$SERVICE";
          text = "Status: failed";
        };

        notifierInfo = pkgs.callPackage ../../../pkgs/special/ntfy-sender.nix {
          inherit config;
          priority = "min";
          title = "$SERVICE";
          text = "Status: succeeded";
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

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
        ntfy = pkgs.callPackage ../../../pkgs/special/ntfy-sender.nix { inherit config; };
      in
      {
        "${cfg.problemServiceName}@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = ''
            ${ntfy} --priority high --tags rotating_light --title "$SERVICE" "❌ failed"
          '';
        };
        "${cfg.infoServiceName}@" = {
          enable = true;
          environment.SERVICE = "%i";
          script = ''
            ${ntfy} --priority min --tags white_check_mark --title "$SERVICE" "✅ succeeded"
          '';
        };
      };
  };
}

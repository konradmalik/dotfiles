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
  # only failures are notified: a job that keeps working every hour on every
  # machine buries the one that stopped, so there is deliberately no success
  # counterpart to the service below
  options.konrad.services.ntfy = {
    enable = lib.mkEnableOption "Enables ntfy services";

    problemServiceName = lib.mkOption {
      type = lib.types.str;
      default = "notify-problem";
      readOnly = true;
      description = "Name of the created systemd service for problems, without @";
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
      };
  };
}

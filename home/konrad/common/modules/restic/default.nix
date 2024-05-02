{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.restic;
in
{
  options.konrad.programs.restic = {
    enable = mkEnableOption "Enables restic backups through home-manager and backblaze b2";

    b2ApplicationId = mkOption {
      type = types.str;
      example = "12345";
      description = "backblaze account id";
      default = "0035814e69b653f0000000006";
    };

    b2ApplicationKeySopsRef = mkOption {
      type = types.str;
      example = "restic/b2_application_key";
      default = "restic/b2_application_key";
      description = "sops nix reference containing backblaze account key";
    };

    b2Bucket = mkOption {
      type = types.str;
      example = "somebucket";
      description = "b2 bucket to use for the restic repo";
      default = "backups-km";
    };

    passwordFileSopsRef = mkOption {
      type = types.str;
      description = "sops nix reference containing restic password";
      example = "restic/password";
      default = "restic/password";
    };

    ntfyPathFileRef = mkOption {
      type = types.str;
      description = "sops nix reference containing ntfy.sh url path for notifications";
      example = "restic/ntfy_restic_path";
      default = "restic/ntfy_restic_path";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Package for restic";
      example = "pkgs.restic";
    };

    includes = lib.mkOption {
      type = lib.types.listOf (lib.types.str);
      description = "What to include";
      example = [
        "${config.home.homeDirectory}/Code/scratch"
        "${config.home.homeDirectory}/Documents"
        "${config.home.homeDirectory}/obsidian"
      ];
    };

    excludes = lib.mkOption {
      type = lib.types.listOf (lib.types.str);
      description = "What to exclude";
      example = [
        "**/node_modules/"
        "**/.DS_Store"
        "**/.stfolder"
      ];
      default = [
        "**/.DS_Store"
        "**/.direnv"
      ];
    };
  };

  # great reference https://hugoreeves.com/posts/2019/backups-with-restic/
  config =
    let
      repostiory = "b2:${cfg.b2Bucket}";
      b2ApplicationKeyFile = config.sops.secrets.${cfg.b2ApplicationKeySopsRef}.path;
      passwordFile = config.sops.secrets.${cfg.passwordFileSopsRef}.path;
      restic = cfg.package;

      baker = pkgs.callPackage ./baker.nix {
        inherit
          b2ApplicationKeyFile
          repostiory
          passwordFile
          restic
          ;
        inherit (cfg) includes excludes b2ApplicationId;
      };

      mkUnit = command: script: {
        Unit = {
          Description = "Restic ${command}";
          After = [
            "sops-nix.service"
            "network.target"
          ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${script}";
        };
      };

      mkTimer = command: interval: {
        Unit = {
          Description = "Restic ${command} timer";
        };

        Install.WantedBy = [ "timers.target" ];

        Timer = {
          Unit = "restic-${command}.service";
          OnCalendar = interval;
          Persistent = true;
        };
      };

      mkAgent = command: script: interval: {
        enable = true;
        config = {
          ProcessType = "Background";
          Program = "${script}";
          RunAtLoad = false;
          StandardOutPath = "/tmp/restic/${command}/stdout";
          StandardErrorPath = "/tmp/restic/${command}/stderr";
          StartCalendarInterval = interval;
        };
      };

      ntfyPath = config.sops.secrets.${cfg.ntfyPathFileRef}.path;
      command = name: cmd: pkgs.callPackage ./cmd.nix { inherit name cmd ntfyPath; };

      resticBackup = command "restic-backup" "${baker}/bin/baker b2 backup";
      resticForget = command "restic-forget" "${baker}/bin/baker b2 forget-prune";
      resticCheck = command "restic-check" "${baker}/bin/restic-b2 check";
    in
    mkIf cfg.enable {
      sops.secrets = {
        ${cfg.b2ApplicationKeySopsRef} = {
          path = "${config.xdg.dataHome}/restic/envs/b2/application_key";
        };
        ${cfg.passwordFileSopsRef} = {
          path = "${config.xdg.dataHome}/restic/password";
        };
        ${cfg.ntfyPathFileRef} = {
          path = "${config.xdg.dataHome}/restic/ntfy_restic_path";
        };
      };

      home.packages = [ baker ];

      systemd.user.services = {
        "restic-backup" = mkUnit "backup" resticBackup;
        "restic-forget" = mkUnit "forget" resticForget;
        "restic-check" = mkUnit "check" resticCheck;
      };

      systemd.user.timers = {
        "restic-backup" = mkTimer "backup" "hourly";
        "restic-forget" = mkTimer "forget" "Mon";
        "restic-check" = mkTimer "check" "Fri";
      };

      launchd.agents = {
        "restic-backup" = mkAgent "backup" resticBackup [ { Minute = 0; } ];
        # Saturday
        "restic-check" = mkAgent "check" resticCheck [ { Weekday = 6; } ];
        # Sunday
        "restic-forget" = mkAgent "forget" resticForget [ { Weekday = 0; } ];
      };
    };
}

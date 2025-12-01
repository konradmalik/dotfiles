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

    b2ApplicationKeyFile = mkOption {
      type = types.str;
      description = "file containing backblaze account key";
    };

    b2Bucket = mkOption {
      type = types.str;
      example = "somebucket";
      description = "b2 bucket to use for the restic repo";
      default = "backups-km";
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
        "**/node_modules/"
        "**/.DS_Store"
        "**/.direnv"
      ];
    };
  };

  # great reference https://hugoreeves.com/posts/2019/backups-with-restic/
  config =
    let
      repostiory = "b2:${cfg.b2Bucket}";
      restic = cfg.package;

      baker = pkgs.callPackage ./baker.nix {
        inherit
          repostiory
          restic
          ;
        inherit (cfg)
          includes
          excludes
          b2ApplicationId
          ;

        passwordFile = config.sops.secrets."restic/password".path;
        b2ApplicationKeyFile = config.sops.secrets."restic/b2_application_key".path;
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
          ExecStartPre = "${lib.getExe pkgs.flock} --exclusive --timeout 60 /tmp/baker.lock echo acquired lock";
          ExecStart = script;
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
          ProgramArguments = [
            "${lib.getExe pkgs.flock}"
            "--exclusive"
            "--timeout"
            "60"
            "/tmp/baker.lock"
            script
          ];
          RunAtLoad = false;
          StandardOutPath = "/tmp/restic/${command}/stdout";
          StandardErrorPath = "/tmp/restic/${command}/stderr";
          StartCalendarInterval = interval;
        };
      };

      command =
        name: cmd:
        let
          notifierError = pkgs.callPackage ../../../../../pkgs/special/ntfy-sender.nix {
            inherit config;
            priority = "high";
            tags = "warning";
            title = "baker";
            text = "${name} failed";
          };

          notifierInfo = pkgs.callPackage ../../../../../pkgs/special/ntfy-sender.nix {
            inherit config;
            priority = "min";
            title = "baker";
            text = "${name} succeeded";
          };
        in
        pkgs.writeShellScript "${name}.sh"
          # bash
          ''
            echo "${name}"
            ${pkgs.coreutils}/bin/date
            ${cmd}
            code=$?
            if [[ "$code" == 0 ]]; then
              ${notifierInfo}
            else
              ${notifierError}
            fi
            echo
          '';

      resticBackup = command "restic-backup" "${baker}/bin/baker b2 backup";
      resticForget = command "restic-forget" "${baker}/bin/baker b2 forget-prune";
      resticCheck = command "restic-check" "${baker}/bin/restic-b2 check";
    in
    mkIf cfg.enable {
      sops.secrets =
        let
          sopsFile = ../../../../../hosts/common/users/konrad/secrets.yaml;
        in
        {
          "restic/b2_application_key" = { };
          "restic/password" = { };
          "ntfy/token" = { inherit sopsFile; };
          "ntfy/topic" = { inherit sopsFile; };
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

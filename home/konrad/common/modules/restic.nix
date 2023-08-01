{ config, lib, pkgs, ... }:
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

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Package for restic";
      example = "pkgs.restic";
    };

    includes = lib.mkOption {
      type = lib.types.listOf (lib.types.str);
      description = "What to include";
      example =
        [
          "${config.home.homeDirectory}/Code/scratch"
          "${config.home.homeDirectory}/Documents"
          "${config.home.homeDirectory}/obsidian"
        ];
    };

    excludes = lib.mkOption {
      type = lib.types.listOf (lib.types.str);
      description = "What to exclude";
      example =
        [
          "**/node_modules/"
          "**/.DS_Store"
          "**/.stfolder"
        ];
      default = [ "**/.DS_Store" "**/.direnv" ];
    };
  };

  # great reference https://hugoreeves.com/posts/2019/backups-with-restic/
  config =
    let
      repostiory = "b2:${cfg.b2Bucket}";
      # wraps restic with backblaze env with all configs in one place
      b2ApplicationKeyFile = config.sops.secrets.${cfg.b2ApplicationKeySopsRef}.path;
      passwordFile = config.sops.secrets.${cfg.passwordFileSopsRef}.path;
      b2-env = pkgs.writeText "restic-b2-env"
        ''
          export B2_ACCOUNT_ID="${cfg.b2ApplicationId}"
          export B2_ACCOUNT_KEY="''$(<${b2ApplicationKeyFile})"

          export RESTIC_REPOSITORY="${repostiory}"
          export RESTIC_PASSWORD_FILE="${passwordFile}"

          export KEEP_LAST=3
          export RETENTION_HOURS=12
          export RETENTION_DAYS=7
          export RETENTION_WEEKS=4
          export RETENTION_MONTHS=12
          export RETENTION_YEARS=2
        '';
      includeFile = pkgs.writeText "restic-include"
        (lib.strings.concatStringsSep "\n" cfg.includes);
      excludeFile = pkgs.writeText "restic-exclude"
        (lib.strings.concatStringsSep "\n" cfg.excludes);
      restic-b2 = pkgs.writeShellScriptBin "restic-b2"
        ''
          source "${b2-env}"

          ${cfg.package}/bin/restic "''$@"
        '';
      baker = pkgs.writeShellScriptBin "baker"
        ''
          # Args to be passed to the restic invocation
          args=()

          # The repo is the first argument
          case ''$1 in
            b2)
              source "${b2-env}"
              echo "Running command using B2, repository: ''$RESTIC_REPOSITORY"
              ;;
            *)
              echo "The first argument is the repository to use for the backup, the options are..."
              echo "b2: Backblaze B2 cloud storage repository."
              exit
              ;;
          esac

          # The command to execute comes second
          case ''$2 in
            backup)
              echo "Backing up."
              echo "Directories:"
              cat "${includeFile}"
              echo

              args+=( 'backup' )
              args+=( '--exclude-file' "${excludeFile}" )
              args+=( "--files-from" "${includeFile}" )
              ;;

            forget)
              echo "Forgetting old snapshots"

              args+=(
                "forget"
                "--host" "''$(hostname)"
                "--group-by" "paths"
                "--keep-last" "''$KEEP_LAST"
                "--keep-hourly" "''$RETENTION_HOURS"
                "--keep-daily" "''$RETENTION_DAYS"
                "--keep-weekly" "''$RETENTION_WEEKS"
                "--keep-monthly" "''$RETENTION_MONTHS"
                "--keep-yearly" "''$RETENTION_YEARS"
              )
              ;;

            forget-prune)
              echo "Forgetting and pruning old snapshots"

              args+=(
                "forget"
                "--prune"
                "--host" "''$(hostname)"
                "--group-by" "paths"
                "--keep-last" "$KEEP_LAST"
                "--keep-hourly" "$RETENTION_HOURS"
                "--keep-daily" "$RETENTION_DAYS"
                "--keep-weekly" "$RETENTION_WEEKS"
                "--keep-monthly" "$RETENTION_MONTHS"
                "--keep-yearly" "$RETENTION_YEARS"
              )
              ;;

            *)
              echo "The second argument is the operation to run, the options are..."
              echo "backup: Backup files"
              echo "forget: Forgets snapshots according to the retention policies"
              echo "forget-prune: Like forget but also prunes unused data from the repository"
              exit
              ;;
          esac

          ${cfg.package}/bin/restic "''${args[@]}"
        '';

      mkUnit = command: {
        Unit = {
          Description = "Restic ${command}";
          After = [ "sops-nix.service" "network.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${baker}/bin/baker b2 ${command}";
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

      mkAgent = command: interval: {
        enable = true;
        config = {
          ProcessType = "Background";
          ProgramArguments = [ "${baker}/bin/baker" "b2" command ];
          RunAtLoad = false;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/restic-${command}/stdout";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/restic-${command}/stderr";
          StartCalendarInterval = interval;
        };
      };
    in
    mkIf cfg.enable {
      sops.secrets = {
        ${cfg.b2ApplicationKeySopsRef} = {
          path = "${config.xdg.dataHome}/restic/envs/b2/application_key";
        };
        ${cfg.passwordFileSopsRef} = {
          path = "${config.xdg.dataHome}/restic/password";
        };
      };

      home = {
        packages = [ restic-b2 baker ];
      };

      systemd.user.services = {
        "restic-backup" = mkUnit "backup";
      };

      systemd.user.timers = {
        "restic-backup" = mkTimer "backup" "hourly";
      };

      launchd.agents = {
        "restic-backup" = mkAgent "backup" [{ Minute = 0; }];
      };
    };
}

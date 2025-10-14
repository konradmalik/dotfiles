{
  lib,
  includes,
  excludes,
  b2ApplicationId,
  b2ApplicationKeyFile,
  repostiory,
  passwordFile,
  symlinkJoin,
  writeText,
  writeShellScriptBin,
  restic,
}:
let
  includeFile = writeText "restic-include" (lib.strings.concatStringsSep "\n" includes);
  excludeFile = writeText "restic-exclude" (lib.strings.concatStringsSep "\n" excludes);

  # wraps restic with backblaze env with all configs in one place
  b2-env =
    writeText "restic-b2-env"
      # bash
      ''
        export B2_ACCOUNT_ID="${b2ApplicationId}"
        export B2_ACCOUNT_KEY="$(<${b2ApplicationKeyFile})"

        export RESTIC_REPOSITORY="${repostiory}"
        export RESTIC_PASSWORD_FILE="${passwordFile}"

        export KEEP_LAST=3
        export RETENTION_HOURS=12
        export RETENTION_DAYS=7
        export RETENTION_WEEKS=4
        export RETENTION_MONTHS=12
        export RETENTION_YEARS=2
      '';
  restic-b2 = writeShellScriptBin "restic-b2" ''
    source "${b2-env}"
    ${restic}/bin/restic "''$@"
  '';
  baker = writeShellScriptBin "baker" ''
    source "${b2-env}"

    # Args to be passed to the restic invocation
    args=()

    # The repo is the first argument
    case ''$1 in
      b2)
        echo "Running command using B2, repository: $RESTIC_REPOSITORY"
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
          "--group-by" "paths"
          "--keep-last" "$KEEP_LAST"
          "--keep-hourly" "$RETENTION_HOURS"
          "--keep-daily" "$RETENTION_DAYS"
          "--keep-weekly" "$RETENTION_WEEKS"
          "--keep-monthly" "$RETENTION_MONTHS"
          "--keep-yearly" "$RETENTION_YEARS"
        )
        ;;

      forget-prune)
        echo "Forgetting and pruning old snapshots"

        args+=(
          "forget"
          "--prune"
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

    ${restic}/bin/restic "''${args[@]}"
  '';
in
symlinkJoin {
  name = "baker";
  paths = [
    baker
    restic-b2
  ];
}

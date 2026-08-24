{
  lib,
  includes,
  excludes,
  retention,
  retryLock,
  repository,
  passwordFile,
  applicationKeyId,
  applicationKeyFile,
  symlinkJoin,
  writeText,
  writeShellScriptBin,
  restic,
}:
let
  includeFile = writeText "restic-include" (lib.strings.concatStringsSep "\n" includes);
  excludeFile = writeText "restic-exclude" (lib.strings.concatStringsSep "\n" excludes);

  # all config in one place, sourced by both wrappers below.
  # backblaze is used through its s3-compatible api because the native b2 backend
  # has known error handling issues, see restic docs "preparing a new repository".
  env =
    writeText "restic-env"
      # bash
      ''
        export AWS_ACCESS_KEY_ID="${applicationKeyId}"
        export AWS_SECRET_ACCESS_KEY="$(<${applicationKeyFile})"

        export RESTIC_REPOSITORY="${repository}"
        export RESTIC_PASSWORD_FILE="${passwordFile}"
      '';

  # --retry-lock is a global flag, so every command below waits for a lock held by
  # another host's running backup instead of failing immediately. Without it, an
  # exclusive lock (forget --prune) fails the moment any other host is backing up.
  restic-b2 = writeShellScriptBin "restic-b2" ''
    source "${env}"
    exec ${restic}/bin/restic --retry-lock "${retryLock}" "$@"
  '';

  # host,paths is restic's default: with a single repo shared by all machines,
  # grouping by paths only would pool every host into one retention group, so one
  # machine's snapshots could satisfy the policy and another's be forgotten whole.
  retentionArgs = lib.strings.concatStringsSep " " [
    "--group-by host,paths"
    "--keep-last ${toString retention.last}"
    "--keep-hourly ${toString retention.hourly}"
    "--keep-daily ${toString retention.daily}"
    "--keep-weekly ${toString retention.weekly}"
    "--keep-monthly ${toString retention.monthly}"
    "--keep-yearly ${toString retention.yearly}"
  ];

  baker = writeShellScriptBin "baker" ''
    set -uo pipefail

    restic="${restic-b2}/bin/restic-b2"

    usage() {
      echo "usage: baker <command>"
      echo
      echo "commands:"
      echo "  backup        back up the configured directories"
      echo "  forget        forget snapshots according to the retention policy"
      echo "  forget-prune  like forget, but also prune unused data from the repository"
      echo "  check         verify the repository structure"
      echo "  snapshots     list snapshots"
      echo "  unlock        remove stale locks"
      echo "  unlock-all    remove ALL locks, even live ones (nothing may be running)"
      echo "  init          initialize the repository"
    }

    # An interrupted run (a laptop going to sleep mid-backup) leaves its lock in the
    # repository. restic only considers a lock stale once it has not been refreshed
    # for 30 minutes, so this can never race a live run on any host - but nothing
    # ever cleaned those up before, so they had to be removed by hand.
    unlock_stale() {
      echo "--> removing stale locks"
      "$restic" unlock
    }

    case "''${1-}" in
      backup)
        echo "--> backing up:"
        cat "${includeFile}"
        unlock_stale
        exec "$restic" backup \
          --exclude-file "${excludeFile}" \
          --exclude-caches \
          --exclude-if-present .nobackup \
          --files-from "${includeFile}"
        ;;

      forget)
        echo "--> forgetting old snapshots"
        unlock_stale
        exec "$restic" forget ${retentionArgs}
        ;;

      forget-prune)
        echo "--> forgetting and pruning old snapshots"
        unlock_stale
        exec "$restic" forget --prune --cleanup-cache ${retentionArgs}
        ;;

      check)
        echo "--> checking the repository"
        unlock_stale
        exec "$restic" check --cleanup-cache
        ;;

      snapshots | init)
        exec "$restic" "$1"
        ;;

      unlock)
        exec "$restic" unlock
        ;;

      unlock-all)
        exec "$restic" unlock --remove-all
        ;;

      *)
        usage
        exit 1
        ;;
    esac
  '';
in
symlinkJoin {
  name = "baker";
  paths = [
    baker
    restic-b2
  ];
}

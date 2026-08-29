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

    b2ApplicationKeyId = mkOption {
      type = types.str;
      example = "12345";
      description = "backblaze application key id";
      default = "0035814e69b653f0000000006";
    };

    b2Bucket = mkOption {
      type = types.str;
      example = "somebucket";
      description = "b2 bucket to use for the restic repo";
      default = "backups-km";
    };

    b2S3Endpoint = mkOption {
      type = types.str;
      example = "s3.us-west-004.backblazeb2.com";
      description = ''
        Backblaze s3-compatible endpoint hosting the bucket. Shown in the b2 console
        on the bucket details page. Must match the account's realm, otherwise every
        restic invocation fails to reach the repository.
      '';
      default = "s3.eu-central-003.backblazeb2.com";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Package for restic";
      example = "pkgs.restic";
    };

    retryLock = mkOption {
      type = types.str;
      example = "15m";
      description = ''
        How long restic retries acquiring the repository lock. All machines share one
        repo, so an exclusive operation (forget --prune) collides with any other
        host's running backup; without retries it fails immediately.
      '';
      default = "1h";
    };

    retention = mkOption {
      description = "Retention policy used by forget and forget-prune";
      default = { };
      type = types.submodule {
        options = {
          last = mkOption {
            type = types.int;
            default = 3;
            description = "keep the last n snapshots";
          };
          hourly = mkOption {
            type = types.int;
            default = 12;
            description = "keep the last n hourly snapshots";
          };
          daily = mkOption {
            type = types.int;
            default = 7;
            description = "keep the last n daily snapshots";
          };
          weekly = mkOption {
            type = types.int;
            default = 4;
            description = "keep the last n weekly snapshots";
          };
          monthly = mkOption {
            type = types.int;
            default = 12;
            description = "keep the last n monthly snapshots";
          };
          yearly = mkOption {
            type = types.int;
            default = 2;
            description = "keep the last n yearly snapshots";
          };
        };
      };
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
      baker = pkgs.callPackage ./baker.nix {
        inherit (cfg)
          includes
          excludes
          retention
          retryLock
          ;

        restic = cfg.package;
        repository = "s3:${cfg.b2S3Endpoint}/${cfg.b2Bucket}";
        applicationKeyId = cfg.b2ApplicationKeyId;
        applicationKeyFile = config.sops.secrets."restic/b2_application_key".path;
        passwordFile = config.sops.secrets."restic/password".path;
      };

      # local mutex, unrelated to the restic lock inside the repository: it only
      # keeps two baker jobs on this machine from running at the same time.
      lockFile = "/tmp/baker.lock";
      lockTimeout = 900;

      # wraps a baker command with the local mutex, logging and notifications.
      runner =
        name: job:
        let
          ntfy = pkgs.callPackage ../../../../../pkgs/special/ntfy-sender.nix { inherit config; };
        in
        pkgs.writeShellScript "restic-${name}.sh"
          # bash
          ''
            set -uo pipefail

            export PATH="${
              lib.makeBinPath [
                pkgs.coreutils
                pkgs.flock
                pkgs.gnugrep
              ]
            }:$PATH"

            log="$(mktemp)"
            trap 'rm -f "$log"' EXIT

            notify() { ${ntfy} --priority "$1" --tags "$2" --title "baker: ${name}"; }

            # restic's documented exit codes, because a bare "exit 11" gives no
            # clue that the repository was simply locked by another host
            reason() {
              case "$1" in
                1) echo "command failed" ;;
                2) echo "go runtime error" ;;
                3) echo "some source data could not be read" ;;
                10) echo "repository does not exist" ;;
                11) echo "failed to lock the repository" ;;
                12) echo "wrong password" ;;
                130) echo "interrupted" ;;
                *) echo "unknown error" ;;
              esac
            }

            exec 9>"${lockFile}"
            if ! flock --exclusive --timeout ${toString lockTimeout} 9; then
              msg="skipped, another baker run is still holding the lock"
              echo "$msg"
              notify low hourglass_flowing_sand <<< "$msg"
              exit 0
            fi

            echo "=== ${name} started $(date)"
            start="$SECONDS"
            ${baker}/bin/baker ${job.command} 2>&1 | tee "$log"
            code="''${PIPESTATUS[0]}"
            elapsed="$(date -u -d "@$((SECONDS - start))" +%T)"
            echo "=== ${name} finished with exit code $code $(date)"

            # the emoji comes from the ntfy tag below, which is rendered in front of
            # the title, so the body must not repeat it
            case "$code" in
              0) head="succeeded in $elapsed"; prio=min; tag=white_check_mark ;;
              # a backup that could not read some files still wrote a snapshot,
              # so that is a warning rather than a failure
              3) head="warnings in $elapsed: $(reason "$code")"; prio=default; tag=warning ;;
              *) head="failed in $elapsed: $(reason "$code") (exit $code)"; prio=high; tag=x ;;
            esac

            # every restic command ends with its own summary, so the notification
            # body is simply the tail of it, minus progress and blank line noise
            printf '%s\n\n%s\n' "$head" "$(grep -vE '^(\[|$)' "$log" | tail -n 15)" |
              notify "$prio" "$tag"

            exit "$code"
          '';

      # one definition per job, so linux and darwin cannot drift apart.
      # backups are deliberately off the full hour: every machine used to start at
      # :00, which is exactly when the weekly maintenance jobs needed the repo.
      jobs = {
        backup = {
          command = "backup";
          onCalendar = "*:07";
          calendarInterval = [ { Minute = 7; } ];
        };
        check = {
          command = "check";
          onCalendar = "Sat 04:30";
          calendarInterval = [
            {
              Weekday = 6;
              Hour = 4;
              Minute = 30;
            }
          ];
        };
        forget = {
          command = "forget-prune";
          onCalendar = "Sun 04:30";
          calendarInterval = [
            {
              Weekday = 0;
              Hour = 4;
              Minute = 30;
            }
          ];
        };
      };

      scripts = mapAttrs runner jobs;

      mkUnit = name: {
        Unit = {
          Description = "Restic ${name}";
          After = [
            "sops-nix.service"
            "network.target"
          ];
        };

        Service = {
          Type = "oneshot";
          Nice = 19;
          IOSchedulingClass = "idle";
          ExecStart = toString scripts.${name};
        };
      };

      mkTimer = name: job: {
        Unit = {
          Description = "Restic ${name} timer";
        };

        Install.WantedBy = [ "timers.target" ];

        Timer = {
          Unit = "restic-${name}.service";
          OnCalendar = job.onCalendar;
          # all hosts back up to the same repo, so don't let them start in lockstep
          RandomizedDelaySeconds = 900;
          AccuracySec = "1m";
          Persistent = true;
        };
      };

      mkAgent = name: job: {
        enable = true;
        config = {
          ProcessType = "Background";
          LowPriorityIO = true;
          # caffeinate keeps idle and disk sleep away for the duration of the run:
          # a suspended restic stops refreshing its repository lock, gets killed and
          # leaves the lock behind.
          ProgramArguments = [
            "/usr/bin/caffeinate"
            "-i"
            "-m"
            (toString scripts.${name})
          ];
          RunAtLoad = false;
          # /tmp is wiped on reboot, which left no trace of failed runs
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/restic/${name}.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/restic/${name}.log";
          # every key left out here is a wildcard, so an entry without Hour and
          # Minute launches the job every single minute of that weekday
          StartCalendarInterval = job.calendarInterval;
        };
      };
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

      systemd.user.services = mapAttrs' (name: _: nameValuePair "restic-${name}" (mkUnit name)) jobs;

      systemd.user.timers = mapAttrs' (name: job: nameValuePair "restic-${name}" (mkTimer name job)) jobs;

      launchd.agents = mapAttrs' (name: job: nameValuePair "restic-${name}" (mkAgent name job)) jobs;
    };
}

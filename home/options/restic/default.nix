{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.konrad.programs.restic;
  inherit (lib) mkOption types;

  repositoryModule = {
    options = {
      repository = mkOption {
        type = types.str;
        example = "/mnt/backup/restic";
        description = "restic repository location, as in RESTIC_REPOSITORY";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "extra environment for restic, usually backend settings";
      };

      environmentFiles = mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          AWS_SECRET_ACCESS_KEY = "/run/secrets/key";
        };
        description = "like environment, but each value is read from the given file when baker runs, for secrets";
      };

      includes = mkOption {
        type = types.listOf types.str;
        description = "paths to back up";
      };

      retention = mkOption {
        type = types.attrsOf (types.either types.int types.str);
        example = {
          within = "1d";
          monthly = "unlimited";
        };
        description = ''
          retention policy, each entry becomes a --keep-<name> flag of restic forget.
          Setting one entry keeps the defaults for the others.
        '';
      };

      backupMinute = mkOption {
        type = types.ints.between 0 59;
        default = 7;
        description = ''
          minute of every hour at which the backup runs. Keep it off the full hour
          and away from other repositories, so jobs don't all start at once.
        '';
      };

      maintenanceHour = mkOption {
        type = types.ints.between 0 23;
        default = 4;
        description = "hour at which the weekly check (saturday) and prune (sunday) run";
      };

      maxSnapshotAgeDays = mkOption {
        type = types.nullOr types.int;
        default = 3;
        description = ''
          How old this host's newest snapshot may get before the daily watchdog
          complains, null disables the watchdog. Nothing checks anything while the
          machine is off, so this only fires on a machine that is running but has
          stopped producing snapshots.
        '';
      };
    };

    # mkDefault per entry, so a host overriding one of them keeps the rest
    config.retention = lib.mapAttrs (_: lib.mkDefault) {
      last = 3;
      hourly = 12;
      daily = 7;
      weekly = 4;
      monthly = 12;
      yearly = 2;
    };
  };

  baker = pkgs.writeShellApplication {
    name = "baker";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      jq
      restic
      custom.scripts.ntfy-send
    ];
    # baker.sh sets its own options, errexit deliberately not among them
    bashOptions = [ ];
    text = builtins.readFile ./baker.sh;
  };

  excludeFile = pkgs.writeText "baker-excludes" (lib.concatLines cfg.excludes);

  # baker-<name>: baker bound to one repository through its environment
  mkWrapper =
    name: repo:
    let
      exports = {
        RESTIC_REPOSITORY = repo.repository;
        RESTIC_PASSWORD_FILE = cfg.passwordFile;
        BAKER_NAME = name;
        BAKER_INCLUDE_FILE = pkgs.writeText "baker-${name}-includes" (lib.concatLines repo.includes);
        BAKER_EXCLUDE_FILE = excludeFile;
        BAKER_KEEP = toString (lib.mapAttrsToList (k: v: "--keep-${k} ${toString v}") repo.retention);
        BAKER_NTFY_TOKEN_FILE = cfg.ntfy.tokenFile;
        BAKER_NTFY_TOPIC_FILE = cfg.ntfy.topicFile;
      }
      // lib.optionalAttrs (repo.maxSnapshotAgeDays != null) {
        BAKER_MAX_AGE_DAYS = toString repo.maxSnapshotAgeDays;
      }
      // repo.environment;
    in
    pkgs.writeShellScriptBin "baker-${name}" ''
      ${lib.concatLines (lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") exports)}
      ${lib.concatLines (
        lib.mapAttrsToList (k: file: "export ${k}=\"$(<${lib.escapeShellArg file})\"") repo.environmentFiles
      )}
      exec ${lib.getExe baker} "$@"
    '';

  wrappers = lib.mapAttrs mkWrapper cfg.repositories;

  # Every scheduled job, keyed by its unit name. `at` uses launchd's calendar
  # keys, the systemd schedule is derived from it so the two cannot drift apart.
  jobs = lib.concatMapAttrs (
    name: repo:
    let
      job = command: at: {
        "baker-${name}-${builtins.head command}" = {
          inherit at;
          exec = [
            (lib.getExe wrappers.${name})
            "run"
          ]
          ++ command;
        };
      };
    in
    job [ "backup" ] { Minute = repo.backupMinute; }
    // job [ "check" "--cleanup-cache" ] {
      Weekday = 6;
      Hour = repo.maintenanceHour;
      Minute = 30;
    }
    // job [ "forget" "--prune" "--cleanup-cache" ] {
      Weekday = 0;
      Hour = repo.maintenanceHour;
      Minute = 30;
    }
    // lib.optionalAttrs (repo.maxSnapshotAgeDays != null) (
      job [ "watchdog" ] {
        Hour = 12;
        Minute = 20;
      }
    )
  ) cfg.repositories;

  onCalendar =
    {
      Weekday ? null,
      Hour ? null,
      Minute,
    }:
    lib.optionalString (Weekday != null) (
      builtins.elemAt [
        "Sun"
        "Mon"
        "Tue"
        "Wed"
        "Thu"
        "Fri"
        "Sat"
      ] Weekday
      + " "
    )
    + "${if Hour == null then "*" else toString Hour}:${lib.fixedWidthNumber 2 Minute}";

  darwinLogDir = "${config.home.homeDirectory}/Library/Logs/baker";
in
{
  options.konrad.programs.restic = {
    enable = lib.mkEnableOption "restic backups";

    repositories = mkOption {
      type = types.attrsOf (types.submodule repositoryModule);
      default = { };
      description = ''
        Repositories to back up to, each gets its own baker-<name> command and
        scheduled jobs.
      '';
    };

    excludes = mkOption {
      type = types.listOf types.str;
      default = import ./excludes.nix config.home.homeDirectory;
      description = "restic exclude patterns, shared by all repositories";
    };

    passwordFile = mkOption {
      type = types.str;
      description = "file holding the password, shared by all repositories";
    };

    ntfy = {
      tokenFile = mkOption {
        type = types.str;
        description = "file holding the ntfy access token for failure notifications";
      };
      topicFile = mkOption {
        type = types.str;
        description = "file holding the ntfy topic for failure notifications";
      };
    };
  };

  # great reference https://hugoreeves.com/posts/2019/backups-with-restic/
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { home.packages = lib.attrValues wrappers; }

      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.services = lib.mapAttrs (name: job: {
          Unit = {
            Description = name;
            # the user manager has no network.target to order against, only this
            After = [ "sops-nix.service" ];
          };
          Service = {
            Type = "oneshot";
            Nice = 19;
            IOSchedulingClass = "idle";
            ExecStart = lib.escapeShellArgs job.exec;
          };
        }) jobs;

        systemd.user.timers = lib.mapAttrs (name: job: {
          Unit.Description = name;
          Install.WantedBy = [ "timers.target" ];
          Timer = {
            OnCalendar = onCalendar job.at;
            # hosts sharing a repository must not start in lockstep
            RandomizedDelaySec = 900;
            AccuracySec = "1m";
            Persistent = true;
          };
        }) jobs;
      })

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        launchd.agents = lib.mapAttrs (name: job: {
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
            ]
            ++ job.exec;
            RunAtLoad = false;
            # /tmp is wiped on reboot, which left no trace of failed runs
            StandardOutPath = "${darwinLogDir}/${name}.log";
            StandardErrorPath = "${darwinLogDir}/${name}.log";
            # every key left out is a wildcard, so an entry without Hour and Minute
            # would launch the job every single minute of that weekday
            StartCalendarInterval = [ job.at ];
          };
        }) jobs;

        # launchd opens the log files itself and does not create their directory
        home.activation.bakerLogDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p ${lib.escapeShellArg darwinLogDir}
        '';
      })
    ]
  );
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.konrad.services.borg;
in
{
  options.konrad.services.borg = {
    enable = lib.mkEnableOption "Enables borg backups";

    name = lib.mkOption {
      type = lib.types.str;
      example = "my-job";
      description = "name of the job";
    };

    repoPath = lib.mkOption {
      type = lib.types.path;
      example = "/mnt/borg/somerepo";
      description = "Path to the borg backups repository";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      example = "/tmp/pass.txt";
      description = "Path to the borg password file";
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      example = ''[ "/home/konrad" "/var/mydatabase" ]'';
      description = "paths to backup";
    };

    systemdName = lib.mkOption {
      type = lib.types.str;
      default = "borgbackup-job-${cfg.name}";
      readOnly = true;
      description = "Name of the created systemd service. Read only, changing this does not do anything.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.jobs = {
      ${cfg.name} = {
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${cfg.passwordFile}";
        };
        extraCreateArgs = [
          "--verbose"
          "--stats"
          "--checkpoint-interval"
          "600"
          "--exclude-caches"
          "--exclude-if-present"
          ".nobackup"
          "--keep-exclude-tags"
        ];
        # backing up a live home always races with running apps, and a single
        # "file changed while we backed it up" warning would otherwise abort the
        # job and leave the archive stuck with the .failed suffix
        failOnWarnings = false;
        repo = cfg.repoPath;
        compression = "zstd,1";
        startAt = "*-*-* *:30:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
        # fnmatch style: "*" matches "/" too, so "/home/*/.cache" hits any
        # .cache at any depth. No trailing slash means borg skips the directory
        # instead of descending into it.
        exclude = [
          "*.o"
          "*.pyc"
          "*.log"
          "*-shm"
          "*-wal"
          "*.sqlite-journal"

          "*/__pycache__"
          "*/node_modules"
          "*/.direnv"
          "*/.mypy_cache"
          "*/.pytest_cache"
          "*/.ruff_cache"
          "/home/*/Code/*/bin"
          "/home/*/Code/*/obj"

          "/home/*/.cache"
          "/home/*/.local/share"
          "/home/*/.local/state"
          "/home/*/Downloads"

          "/home/*/.azcopy"
          "/home/*/.cargo"
          "/home/*/.clangd"
          "/home/*/.dotnet"
          "/home/*/.go"
          "/home/*/.gradle"
          "/home/*/.m2"
          "/home/*/.npm"
          "/home/*/.nuget"
          "/home/*/.opam"
          "/home/*/.pnpm"
          "/home/*/.terraform"
          "/home/*/go"

          "/home/*/.config/Slack"
          "/home/*/.config/syncthing/index-v2"

          "/home/*/.config/*/Cache"
          "/home/*/.config/*/CachedData"
          "/home/*/.config/*/Code Cache"
          "/home/*/.config/*/Crashpad"
          "/home/*/.config/*/DawnCache"
          "/home/*/.config/*/GPUCache"
          "/home/*/.config/*/ShaderCache"
          "/home/*/.config/*/Service Worker/CacheStorage"

          "/home/*/.config/mozilla/firefox/Crash Reports"
          "/home/*/.config/mozilla/firefox/Pending Pings"
          "/home/*/.config/mozilla/firefox/*/crashes"
          "/home/*/.config/mozilla/firefox/*/datareporting"
          "/home/*/.config/mozilla/firefox/*/gmp-*"
          "/home/*/.config/mozilla/firefox/*/minidumps"
          "/home/*/.config/mozilla/firefox/*/saved-telemetry-pings"
          "/home/*/.config/mozilla/firefox/*/security_state"
          "/home/*/.config/mozilla/firefox/*/sessionstore-backups"
          "/home/*/.config/mozilla/firefox/*/storage"
          "/home/*/.config/mozilla/firefox/*/AlternateServices.bin"
          "/home/*/.config/mozilla/firefox/*/bounce-tracking-protection.sqlite"
          "/home/*/.config/mozilla/firefox/*/content-prefs.sqlite"
          "/home/*/.config/mozilla/firefox/*/cookies.sqlite"
          "/home/*/.config/mozilla/firefox/*/domain_to_categories.sqlite"
          "/home/*/.config/mozilla/firefox/*/favicons.sqlite"
          "/home/*/.config/mozilla/firefox/*/protections.sqlite"

          # authoritative copy lives on the imap server, unlike Mail/
          "/home/*/.thunderbird/*/ImapMail"
          "/home/*/.thunderbird/*/crashes"
          "/home/*/.thunderbird/*/datareporting"
          "/home/*/.thunderbird/*/minidumps"
          "/home/*/.thunderbird/*/saved-telemetry-pings"
          "/home/*/.thunderbird/*/global-messages-db.sqlite"
        ];
        paths = cfg.paths;
      };
    };
  };
}

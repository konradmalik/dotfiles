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
        extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
        repo = cfg.repoPath;
        compression = "zstd,1";
        startAt = "*-*-* *:30:00";
        prune.keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
        exclude = [
          "*.o"
          "*.pyc"
          "*/node_modules/*"
          "*.log"

          "/home/*/.cache"
          "/home/*/.cargo"
          "/home/*/.clangd"
          "/home/*/.config/Slack"
          "/home/*/.direnv"
          "/home/*/.go"
          "/home/*/.gradle"
          "/home/*/.local/share"
          "/home/*/.local/state"
          "/home/*/.m2"
          "/home/*/.mozilla/firefox/*/storage"
          "/home/*/.npm"
          "/home/*/.nuget"
          "/home/*/.opam"
          "/home/*/.pnpm"
          "/home/*/Downloads"
          "/home/*/go"
        ];
        paths = cfg.paths;
      };
    };
  };
}

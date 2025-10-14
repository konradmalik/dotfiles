{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

    ./hardware-configuration.nix
    ./disko.nix

    ./../common/modules/hyprland.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "framework";

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.network.wireless.enable = true;
  konrad.services = {
    autoupgrade = {
      enable = true;
      allowReboot = false;
      operation = "boot";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.settings.Login = {
    SleepOperation = "suspend";
    IdleAction = "suspend";
    IdleActionSec = "30min";
  };

  # TODO refactor, extract, reuse
  # TODO nice systemd ntfy https://github.com/ascandella/dotfiles/blob/main/modules/nixos/roles/backups.nix and libnotify
  # TODO directly use secrets in restic
  fileSystems = {
    "/mnt/borg" = {
      device = "/dev/disk/by-partlabel/framework-borg";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  sops.secrets.framework-borg = { };
  sops.secrets."ntfy/topic/problem" = { };
  sops.secrets."ntfy/topic/info" = { };
  sops.secrets."ntfy/token" = { };

  services.borgbackup.jobs = {
    home = {
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets.framework-borg.path}";
      };
      extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
      repo = "/mnt/borg/home";
      compression = "zstd,1";
      startAt = "hourly";
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

        "/home/*/.cache"
        "/home/*/.cargo"
        "/home/*/.clangd"
        "/home/*/.direnv"
        "/home/*/.go"
        "/home/*/.gradle"
        "/home/*/.m2"
        "/home/*/.mozilla/firefox/*/storage"
        "/home/*/.npm"
        "/home/*/.nuget"
        "/home/*/.opam"
        "/home/*/.pnpm"
        "/home/*/Downloads"

      ];
      paths = [ "/home/konrad/" ];
    };
  };

  systemd.services.borgbackup-job-home.unitConfig = {
    RequiresMountsFor = "/mnt/borg";
    OnSuccess = "notify-info@%i.service";
    OnFailure = "notify-problem@%i.service";
  };

  # TODO extract
  systemd.services = {
    "notify-problem@" = {
      enable = true;
      environment.SERVICE = "%i";
      script = ''
        NTFY_TOKEN="$(cat ${config.sops.secrets."ntfy/token".path})"
        ${pkgs.curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
          -H "Authorization: Bearer $NTFY_TOKEN" \
          -H "Title: [$(${pkgs.inetutils}/bin/hostname)] $SERVICE status" \
          -H "tags:warning" \
          -H "prio:high" \
          -d "Failed!" \
          https://ntfy.sh/$(<${config.sops.secrets."ntfy/topic/problem".path})
      '';
    };
    "notify-info@" = {
      enable = true;
      environment.SERVICE = "%i";
      script = ''
        NTFY_TOKEN="$(cat ${config.sops.secrets."ntfy/token".path})"
        ${pkgs.curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
          -H "Authorization: Bearer $NTFY_TOKEN" \
          -H "Title: [$(${pkgs.inetutils}/bin/hostname)] $SERVICE status" \
          -H "prio:min" \
          -d "Succeeded." \
          https://ntfy.sh/$(<${config.sops.secrets."ntfy/topic/info".path})
      '';
    };
  };
}

# The external backup disk and the local restic repository on it.
{ lib, utils, ... }:
let
  disk = "/dev/disk/by-partlabel/framework-borg";
  device = "${utils.escapeSystemdPath disk}.device";
  mountPoint = "/mnt/backup";
in
{
  systemd.mounts = [
    {
      what = disk;
      where = mountPoint;
      type = "ext4";
    }
  ];

  systemd.automounts = [
    {
      where = mountPoint;
      wantedBy = [ device ];
      bindsTo = [ device ];
      after = [ device ];
      automountConfig.TimeoutIdleSec = "5min";
    }
  ];

  # spins the disk down between the hourly backups
  konrad.services.hd-idle.enable = true;

  home-manager.users.konrad =
    { config, ... }:
    {
      konrad.programs.restic.repositories.local = {
        repository = "${mountPoint}/restic";
        includes = [ config.home.homeDirectory ];
        backupMinute = 37;
        maintenanceHour = 5;
        retention = {
          monthly = 24;
          yearly = 5;
        };
        maxSnapshotAgeDays = lib.mkDefault 7;
      };
    };
}

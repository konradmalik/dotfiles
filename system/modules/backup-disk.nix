{ utils, ... }:
let
  disk = "/dev/disk/by-partlabel/framework-borg";
  device = "${utils.escapeSystemdPath disk}.device";
in
{
  systemd.mounts = [
    {
      what = disk;
      where = "/mnt/backup";
      type = "ext4";
    }
  ];

  systemd.automounts = [
    {
      where = "/mnt/backup";
      wantedBy = [ device ];
      bindsTo = [ device ];
      after = [ device ];
      automountConfig.TimeoutIdleSec = "5min";
    }
  ];

  # spins the disk down between the hourly backups
  konrad.services.hd-idle.enable = true;
}

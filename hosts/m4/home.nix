{ config, pkgs, ... }:
{
  # first time; rclone config
  # name it onedrive
  # then:  rclone lsd onedrive: (sanity check)
  # then: baker-onedrive init
  # token expired (unused for 90 days): rclone config reconnect onedrive:
  home.packages = [ pkgs.rclone ];

  konrad.programs.restic.repositories.onedrive = {
    repository = "rclone:onedrive:restic";
    environment = {
      # rclone refreshes the oauth token on its own and writes it back here
      RCLONE_CONFIG = "${config.xdg.configHome}/rclone/rclone.conf";
      # business only
      RCLONE_ONEDRIVE_HARD_DELETE = "true";
    };
    includes = config.konrad.programs.restic.repositories.b2.includes ++ [
      config.xdg.userDirs.projects
      "${config.home.homeDirectory}/Movies"
      "${config.home.homeDirectory}/Music"
      # includes the photos library, with its originals
      "${config.home.homeDirectory}/Pictures"
    ];
    backupMinute = 22;
    maintenanceHour = 5;
  };
}

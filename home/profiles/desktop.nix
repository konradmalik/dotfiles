{ config, lib, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/obsidian";
in
{
  imports = [
    ./nixos.nix
    ../modules/desktop
  ];

  konrad.programs.bitwarden.enable = true;

  konrad.programs.nvim = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/state/spell";
  };

  konrad.programs.restic = {
    enable = true;
    repositories = {
      b2.includes = [
        "${config.home.homeDirectory}/Code/scratch"
        "${config.home.homeDirectory}/Documents"
        obsidianPath
      ];

      # the external disk on framework's dock, shared by every machine that gets
      # docked there. Each host's system config mounts it, a run finding it
      # missing just skips.
      local = {
        repository = "/mnt/backup/restic";
        includes = [ config.home.homeDirectory ];
        backupMinute = 37;
        maintenanceHour = 5;
        # disk space is cheap here, so keep a longer history than offsite:
        # monthly snapshots for two years, yearly ones for five
        retention = {
          monthly = 24;
          yearly = 5;
        };
        # another machine may hold the dock for a few days
        maxSnapshotAgeDays = lib.mkDefault 7;
      };
    };
  };
}

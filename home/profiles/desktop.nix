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

      local = {
        repository = "/mnt/backup/restic";
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
  };
}

{ config, lib, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  imports = [
    ../modules/base
    ../modules/workstation
  ];

  options.konrad.obsidianPath = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/obsidian";
    description = "Root of the synced obsidian vaults.";
  };

  config = {
    konrad.repos = {
      dotfiles.url = "https://github.com/konradmalik/dotfiles";
      neovim.url = "https://github.com/konradmalik/neovim-flake";
    };

    konrad.programs.bitwarden.enable = true;

    konrad.programs.nvim = {
      notesPath = mkOutOfStoreSymlink "${config.konrad.obsidianPath}/Personal";
      spellPath = mkOutOfStoreSymlink "${config.konrad.repos.neovim.path}/state/spell";
    };

    konrad.programs.restic = {
      enable = true;
      repositories.b2.includes = [
        "${config.xdg.userDirs.projects}/scratch"
        "${config.home.homeDirectory}/Documents"
        config.konrad.obsidianPath
      ];
    };
  };
}

{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/obsidian";
in
{
  imports = [
    ../../systems/nixos.nix
    ../../modules/desktop
  ];

  konrad.programs.bitwarden.enable = true;

  programs.neovim-pde = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/files/spell";
    devConfigurationPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/config";
  };

  konrad.programs.restic = {
    enable = true;
    includes = [
      "${config.home.homeDirectory}/Code/scratch"
      "${config.home.homeDirectory}/Documents"
      obsidianPath
    ];
  };
}

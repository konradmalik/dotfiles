{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";
in
{
  imports = [ ../systems/darwin.nix ];

  home.homeDirectory = "/Users/${config.home.username}";

  konrad.programs.bitwarden.enable = true;

  konrad.programs.nvim = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/state/spell";
  };

  konrad.programs.restic = {
    enable = true;
    includes = [
      "${config.home.homeDirectory}/Code/scratch"
      "${config.home.homeDirectory}/Desktop"
      "${config.home.homeDirectory}/Documents"
      obsidianPath
    ];
  };
}

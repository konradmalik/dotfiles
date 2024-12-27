{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";
in
{
  imports = [ ./common/darwin.nix ];

  home.homeDirectory = "/Users/${config.home.username}";

  fontProfiles = {
    enable = true;
    monospace.size = 15.0;
  };
  konrad.programs.bitwarden.enable = true;
  konrad.programs.alacritty = {
    makeDefault = false;
    enable = true;
    # installed via homebrew
    package = null;
  };
  konrad.programs.ghostty = {
    enable = true;
    # installed via homebrew
    package = null;
  };
  programs.neovim-pde = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/files/spell";
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

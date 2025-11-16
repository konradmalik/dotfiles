{ config, pkgs, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";
in
{
  imports = [ ../systems/darwin.nix ];

  home.homeDirectory = "/Users/${config.home.username}";

  konrad.programs.bitwarden = {
    enable = true;
    # FIXME until fixed on unstable
    package = pkgs.stable.bitwarden-cli;
  };

  programs.neovim-pde = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/files/spell";
    devConfigurationPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/config";
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

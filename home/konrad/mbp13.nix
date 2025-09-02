{ config, pkgs, ... }:
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
  konrad.programs.bitwarden = {
    enable = true;
    # TODO until fixed on unstable
    package =
      (builtins.getFlake "github:NixOS/nixpkgs/3cf437fb2e3a4a8e4d28c89699b084636a48b979")
      .legacyPackages.${pkgs.system}.bitwarden-cli;
  };
  konrad.programs.alacritty = {
    makeDefault = false;
    enable = true;
    # installed via homebrew
    package = null;
  };
  programs.ghostty.package = null;
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

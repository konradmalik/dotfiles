{ config, ... }:
let
  obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";
in
{
  imports = [ ./common/darwin.nix ];

  home.homeDirectory = "/Users/${config.home.username}";

  fontProfiles = {
    enable = true;
    monospace.size = 16.0;
  };
  konrad.programs.bitwarden.enable = true;
  konrad.programs.alacritty = {
    enable = true;
    # installed via homebrew
    package = null;
  };
  programs.neovim-pde = {
    systemLua = # lua
      ''
        return {
          repository_path = "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake";
          notes_path = "${obsidianPath}/Personal";
        }
      '';
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

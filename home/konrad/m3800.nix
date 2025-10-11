{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/obsidian";
in
{
  imports = [
    ./common/nixos.nix
    ./common/modules/desktop
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

  konrad.services.syncthing = {
    enable = true;
    install = true;
  };

  wayland.windowManager.hyprland.settings = {
    # exec-once = [ "hyprctl dispatch dpms off 'eDP-1'" ];
    # monitor = [ "eDP-1, disable" ];
    monitor = [ "eDP-1, preferred, auto, 2" ];
    device = {
      name = "elan-touchscreen";
      enabled = false;
    };
  };
}

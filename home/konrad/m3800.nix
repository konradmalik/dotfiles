{ config, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/obsidian";
in
{
  imports = [
    ./common/nixos.nix
    ./common/modules/desktop/hyprland
  ];

  fontProfiles.enable = true;
  konrad.programs.bitwarden.enable = true;
  konrad.programs.alacritty = {
    makeDefault = false;
    enable = true;
  };
  konrad.programs.ghostty.enable = true;
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

  monitors = [
    {
      name = "eDP-1";
      enabled = false;
      width = 3840;
      height = 2160;
      isPrimary = true;
      refreshRate = 59.997;
      scale = 2;
      x = 0;
    }
    {
      name = "HDMI-A-1";
      enabled = true;
      width = 3440;
      height = 1440;
      isPrimary = true;
      refreshRate = 29.993;
      scale = 1;
      x = 0;
    }
  ];
}

{ config, lib, pkgs, dotfiles, ... }:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.unstable.alacritty;
    settings =
      pkgs.lib.readYAML "${dotfiles}/alacritty/alacritty.yml"
      // pkgs.lib.readYAML "${dotfiles}/alacritty/catppuccin.yml";
  };
}


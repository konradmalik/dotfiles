{ config, lib, pkgs, dotfiles, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.unstable.nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
  ];
  programs.alacritty = {
    enable = true;
    package = pkgs.unstable.alacritty;
    settings =
      pkgs.lib.readYAML "${dotfiles}/alacritty/alacritty.yml"
      // pkgs.lib.readYAML "${dotfiles}/alacritty/catppuccin.yml";
  };
}


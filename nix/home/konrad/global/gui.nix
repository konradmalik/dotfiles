{ pkgs, dotfiles, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs;[
    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
    zathura
  ];
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings =
      pkgs.lib.readYAML "${dotfiles}/alacritty/alacritty.yml"
      // pkgs.lib.readYAML "${dotfiles}/alacritty/catppuccin.yml";
  };
}


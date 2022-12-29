{ pkgs, ... }:
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
      pkgs.yaml-utils.readYAML "${pkgs.dotfiles}/alacritty/alacritty.yml"
      // pkgs.yaml-utils.readYAML "${pkgs.dotfiles}/alacritty/catppuccin.yml";
  };
}


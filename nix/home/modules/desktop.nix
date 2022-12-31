{ pkgs, lib, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;[
    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
    zathura
  ];

  xdg.configFile. "alacritty/alacritty.yml".text =
    lib.strings.concatMapStringsSep "\n" builtins.readFile [
      "${pkgs.dotfiles}/alacritty/alacritty.yml"
      "${pkgs.dotfiles}/alacritty/catppuccin.yml"
    ];
}

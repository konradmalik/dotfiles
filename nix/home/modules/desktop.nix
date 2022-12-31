{ pkgs, lib, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;[
    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
  ];

  xdg.configFile. "alacritty/alacritty.yml".text =
    lib.strings.concatMapStringsSep "\n" builtins.readFile [
      "${pkgs.dotfiles}/alacritty/catppuccin.yml"
      # important that alacritty is last, and that font is the last section there
      # makes it simple to lib.mkAfter font size per machine
      "${pkgs.dotfiles}/alacritty/alacritty.yml"
    ];
}

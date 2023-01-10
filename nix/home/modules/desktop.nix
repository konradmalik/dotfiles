{ pkgs, lib, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;[
    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
  ];

  konrad.programs.alacritty.enable = true;
}

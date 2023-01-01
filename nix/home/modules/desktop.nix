{ pkgs, lib, ... }:
{
  imports = [
    ./../../modules/alacritty.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs;[
    (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
  ];

  konrad.programs.alacritty.enable = true;
}

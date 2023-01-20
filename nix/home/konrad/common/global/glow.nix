{ pkgs, lib, ... }:
{
  xdg.configFile."glow/glow.yml".source = "${pkgs.dotfiles}/glow/glow.yml";
  home.packages = [ pkgs.glow ];
}

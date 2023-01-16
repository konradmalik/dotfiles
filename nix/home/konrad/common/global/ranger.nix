{ config, pkgs, ... }:
{
  home.packages = [ pkgs.ranger ];
  xdg.configFile."ranger" = {
    source = "${pkgs.dotfiles}/ranger";
    recursive = true;
  };

}

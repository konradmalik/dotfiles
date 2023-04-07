{ config, pkgs, outputs, ... }:
{
  home.packages = [ pkgs.ranger ];
  xdg.configFile."ranger" = {
    source = "${outputs.lib.dotfiles}/ranger";
    recursive = true;
  };

}

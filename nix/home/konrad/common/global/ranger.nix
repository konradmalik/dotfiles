{ pkgs, customArgs, ... }:
{
  home.packages = [ pkgs.ranger ];
  xdg.configFile."ranger" = {
    source = "${customArgs.dotfiles}/ranger";
    recursive = true;
  };

}

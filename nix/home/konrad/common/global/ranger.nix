{ pkgs, dotfiles, ... }:
{
  home.packages = [ pkgs.ranger ];
  xdg.configFile."ranger" = {
    source = "${dotfiles}/ranger";
    recursive = true;
  };

}

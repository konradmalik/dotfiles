{ pkgs, ... }:
{
  home.packages = [ pkgs.firefox ];
  home.sessionVariables.BROWSER = "firefox";
}

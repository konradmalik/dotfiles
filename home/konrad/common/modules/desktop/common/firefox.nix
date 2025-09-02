{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "firefox.desktop" ];
    "application/x-extension-htm" = [ "firefox.desktop" ];
    "application/x-extension-html" = [ "firefox.desktop" ];
    "application/x-extension-shtml" = [ "firefox.desktop" ];
    "application/x-extension-xht" = [ "firefox.desktop" ];
    "application/x-extension-xhtml" = [ "firefox.desktop" ];
    "application/xhtml+xml" = [ "firefox.desktop" ];
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/chrome" = [ "firefox.desktop" ];
    "x-scheme-handler/ftp" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
  };
  home.packages = [ pkgs.firefox ];
}

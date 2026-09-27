{ lib, ... }:
let
  mimeTypes = [
    "application/vnd.mozilla.xul+xml"
    "application/xhtml+xml"
    "text/html"
    "text/xml"
    "x-scheme-handler/about"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/unknown"
  ];
in
{
  xdg.mimeApps.defaultApplications = lib.genAttrs mimeTypes (_: [ "firefox.desktop" ]);

  home.sessionVariables.BROWSER = "firefox";
  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
      };
      work = {
        id = 1;
      };
    };
  };

  stylix.targets.firefox.profileNames = [
    "home"
    "work"
  ];
}

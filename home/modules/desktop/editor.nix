{ config, lib, ... }:
let
  mimeTypes = [
    "application/json"
    "text/plain"
  ];
  inherit (config.home.sessionVariables) EDITOR TERMINAL;
in
{
  # $EDITOR has no desktop entry of its own, open it in the terminal
  xdg.desktopEntries.editor = {
    name = "Editor";
    exec = "${TERMINAL} -e ${EDITOR} %f";
    mimeType = mimeTypes;
    noDisplay = true;
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs mimeTypes (_: [ "editor.desktop" ]);
}

{ lib, ... }:

let
  hideApps =
    apps:
    lib.genAttrs apps (name: {
      name = name;
      hidden = true;
    });
in
{
  xdg.desktopEntries = hideApps [ ];
}

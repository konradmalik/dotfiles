{ lib, ... }:

let
  hideApps =
    apps:
    lib.genAttrs apps (name: {
      name = name;
      noDisplay = true;
    });
in
{
  # hm: /etc/profiles/per-user/konrad/share/applications
  # system: ?
  xdg.desktopEntries = hideApps [ ];
}

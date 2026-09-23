{
  config,
  lib,
  ...
}:
let
  allHmUsers = builtins.attrNames config.home-manager.users;
  anyHyprlandEnabled = builtins.any (
    user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable
  ) allHmUsers;
in
{
  programs.hyprland.enable = anyHyprlandEnabled;

  # Hyprlock needs PAM access to authenticate, else it fallbacks to su
  security.pam.services.hyprlock = lib.mkIf anyHyprlandEnabled { };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}

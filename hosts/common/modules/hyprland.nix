{
  config,
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

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}

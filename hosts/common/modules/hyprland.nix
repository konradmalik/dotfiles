{
  config,
  pkgs,
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

  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
}

{
  config,
  lib,
  ...
}:
let
  hyprlandUsers = builtins.filter (
    user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable
  ) (builtins.attrNames config.home-manager.users);
  anyHyprlandEnabled = hyprlandUsers != [ ];
in
{
  options.konrad.hyprland.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    readOnly = true;
    internal = true;
    default = hyprlandUsers;
    description = "Home-manager users with hyprland enabled.";
  };

  config = {
    programs.hyprland.enable = anyHyprlandEnabled;

    # Hyprlock needs PAM access to authenticate, else it fallbacks to su
    security.pam.services.hyprlock = lib.mkIf anyHyprlandEnabled { };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}

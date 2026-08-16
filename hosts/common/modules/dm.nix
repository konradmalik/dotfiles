{ config, lib, ... }:
let
  allHmUsers = builtins.attrNames config.home-manager.users;
  hyprlandUsers = builtins.filter (
    user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable
  ) allHmUsers;
in
{
  assertions = [
    {
      assertion = builtins.length hyprlandUsers <= 1;
      message = "greetd autologin needs exactly one hyprland user, got: ${toString hyprlandUsers}";
    }
  ];

  services.greetd = {
    enable = true;
    settings = {
      # required by greetd, only reachable after logging out
      default_session.command = "${config.services.greetd.package}/bin/agreety --cmd start-hyprland";
    }
    // lib.optionalAttrs (hyprlandUsers != [ ]) {
      # autologin on boot
      initial_session = {
        command = "start-hyprland";
        user = builtins.head hyprlandUsers;
      };
    };
  };
}

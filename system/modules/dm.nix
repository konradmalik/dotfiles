{ config, lib, ... }:
let
  hyprlandUsers = config.konrad.hyprland.users;
in
{
  imports = [ ./hyprland.nix ];

  assertions = [
    {
      assertion = builtins.length hyprlandUsers <= 1;
      message = "greetd autologin supports at most one hyprland user, got: ${toString hyprlandUsers}";
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

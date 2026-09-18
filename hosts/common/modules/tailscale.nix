{ config, lib, ... }:
let
  # only the desktop shell needs to drive tailscale from a user session, so the
  # operator is granted on those machines only
  shellUsers = builtins.filter (
    user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable
  ) (builtins.attrNames config.home-manager.users);
in
{
  assertions = [
    {
      assertion = builtins.length shellUsers <= 1;
      message = "tailscale takes a single operator, got shell users: ${toString shellUsers}";
    }
  ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    # lets that user run `tailscale up/down/set` without root, everyone else
    # keeps the read-only access tailscaled hands out by default
    extraSetFlags = lib.optional (shellUsers != [ ]) "--operator=${builtins.head shellUsers}";
  };
}

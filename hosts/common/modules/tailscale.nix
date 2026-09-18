{ config, lib, ... }:
let
  # only the waybar module needs to drive tailscale from a user session, so the
  # operator is granted on those machines only
  waybarUsers = builtins.filter (user: config.home-manager.users.${user}.programs.waybar.enable) (
    builtins.attrNames config.home-manager.users
  );
in
{
  assertions = [
    {
      assertion = builtins.length waybarUsers <= 1;
      message = "tailscale takes a single operator, got waybar users: ${toString waybarUsers}";
    }
  ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    # lets that user run `tailscale up/down/set` without root, everyone else
    # keeps the read-only access tailscaled hands out by default
    extraSetFlags = lib.optional (waybarUsers != [ ]) "--operator=${builtins.head waybarUsers}";
  };
}

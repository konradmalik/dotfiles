{
  imports = [ ./common/profiles/laptop.nix ];

  wayland.windowManager.hyprland.settings = {
    # exec-once = [ "hyprctl dispatch dpms off 'eDP-1'" ];
    # monitor = [ "eDP-1, disable" ];
    device = {
      name = "raydium-corporation-raydium-touch-system";
      enabled = false;
    };
  };
}

{
  imports = [ ./common/profiles/laptop.nix ];

  wayland.windowManager.hyprland.settings = {
    # exec-once = [ "hyprctl dispatch dpms off 'eDP-1'" ];
    # monitor = [ "eDP-1, disable" ];
    monitor = [ "eDP-1, preferred, auto, 2" ];
    device = {
      name = "elan-touchscreen";
      enabled = false;
    };
  };
}

{
  imports = [ ./common/profiles/laptop.nix ];

  wayland.windowManager.hyprland.settings = {
    device = {
      name = "elan-touchscreen";
      enabled = false;
    };
  };
}

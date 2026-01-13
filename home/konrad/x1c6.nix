{
  imports = [ ./common/profiles/laptop.nix ];

  wayland.windowManager.hyprland.settings = {
    device = {
      name = "raydium-corporation-raydium-touch-system";
      enabled = false;
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.konrad.hardware.touchscreen;
in
{
  options.konrad.hardware.touchscreen = {
    name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "raydium-corporation-raydium-touch-system";
      description = ''
        Hyprland device name of the built-in touchscreen, as `hyprctl devices`
        lists it under Touch. Null on machines without one.
      '';
    };

    enabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether the touchscreen takes input when hyprland starts. The bar can
        toggle it at runtime, and starts out showing this.
      '';
    };
  };

  config = lib.mkIf (cfg.name != null) {
    wayland.windowManager.hyprland.settings.device = {
      inherit (cfg) name enabled;
    };
  };
}

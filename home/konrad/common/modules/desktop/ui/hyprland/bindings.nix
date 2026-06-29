{ osConfig, lib, ... }:
let
  isLaptop = osConfig.services.upower.enable;
in
{
  wayland.windowManager.hyprland.extraLuaFiles = {
    bindings = builtins.readFile ./bindings.lua;
  }
  // lib.optionalAttrs isLaptop {
    brightness = builtins.readFile ./brightness.lua;
  };
}

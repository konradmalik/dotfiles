{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  wayland.windowManager.hyprland.settings.exec-once = [ "noctalia-shell" ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
    };
  };
}

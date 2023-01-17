{ inputs, lib, config, pkgs, osConfig, ... }: {
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
  ];

  assertions = [
    {
      assertion = osConfig.programs.hyprland.enable;
      message = "make sure to enable hyprland on the host for required dependencies like xdg-desktop portal etc.";
    }
  ];

  home.packages = with pkgs; [
    swaybg
  ];

  programs.waybar.package = inputs.hyprland.packages.${pkgs.system}.waybar-hyprland;

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig =
      (import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      }) +
      (import ./config.nix {
        inherit (config.konrad) wallpaper;
        inherit (config) colorscheme;
      });
  };
}

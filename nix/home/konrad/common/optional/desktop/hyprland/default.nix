{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../common
    ../common/wayland-wm
    inputs.hyprland.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    swaybg
  ];

  programs.waybar.package = inputs.hyprland.packages.${pkgs.system}.waybar-hyprland;

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig =
      (import ./config.nix {
        inherit (config) colorscheme;
        inherit (config.konrad) wallpaper;
      });
  };
}

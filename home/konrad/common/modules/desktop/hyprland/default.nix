{
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = [
    ../common
    ../wayland-wm
  ];

  assertions = [
    {
      assertion = osConfig.programs.hyprland.enable;
      message = "make sure to enable hyprland on the host for required dependencies like xdg-desktop portal etc.";
    }
  ];

  services.hyprpolkitagent.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    extraConfig =
      (import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      })
      + (import ./config.nix {
        inherit (config) colorscheme;
      });
  };
}

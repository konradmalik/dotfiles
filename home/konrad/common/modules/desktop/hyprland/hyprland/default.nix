{
  lib,
  config,
  osConfig,
  ...
}:
{
  imports = [
    ./bindings.nix
    ./envs.nix
    ./input.nix
    ./looknfeel.nix
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
    settings = {
      "$terminal" = lib.mkDefault "ghostty";
      "$browser" = lib.mkDefault "firefox";
    };
    extraConfig = (
      import ./monitors.nix {
        inherit lib;
        inherit (config) monitors;
      }
    );
  };
}

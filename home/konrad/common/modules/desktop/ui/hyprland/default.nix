{
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
      # fallback rule for any monitor not matching other rules
      monitor = [ ", preferred, auto, 1" ];
    };
  };
}

{
  osConfig,
  pkgs,
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

  home.packages = with pkgs; [
    libnotify
    wl-clipboard
  ];

  # so that gui apps can ask for password
  services.hyprpolkitagent.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    # use from NixOS module
    package = null;
    portalPackage = null;
    configType = "hyprlang";
    settings = {
      # fallback rule for any monitor not matching other rules
      monitor = [ ", preferred, auto, 1" ];
    };
  };
}

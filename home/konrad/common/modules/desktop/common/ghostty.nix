{
  config,
  lib,
  ...
}:
{
  home.sessionVariables.TERMINAL = lib.getExe config.programs.ghostty.package;

  programs.ghostty = {
    enable = lib.mkDefault true;
    settings = {
      confirm-close-surface = false;
      gtk-single-instance = false;
      gtk-titlebar = false;
      mouse-hide-while-typing = true;
      shell-integration-features = true;
    };
  };
}

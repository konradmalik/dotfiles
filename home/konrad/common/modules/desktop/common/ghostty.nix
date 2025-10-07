{
  lib,
  config,
  ...
}:
{
  home.sessionVariables.TERMINAL = "ghostty";

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

{
  config,
  lib,
  ...
}:
let
  pkg = config.programs.ghostty.package;
in
{
  home.sessionVariables.TERMINAL = if pkg != null then lib.getExe pkg else "ghostty";

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

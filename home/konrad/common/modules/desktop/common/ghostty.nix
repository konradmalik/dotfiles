{
  config,
  pkgs,
  lib,
  ...
}:
let
  pkg = config.programs.ghostty.package;
in
{
  home.sessionVariables.TERMINAL = if pkg != null then lib.getExe pkg else "ghostty";

  programs.tmux.extraConfig =
    # bash
    ''
      # overrides for the ghostty (host) terminal features
      set -as terminal-features ",*ghostty*:hyperlinks:osc7:progressbar:overline:extkeys:usstyle"
    '';

  programs.ghostty = {
    enable = lib.mkDefault true;
    settings = {
      confirm-close-surface = false;
      gtk-single-instance = false;
      gtk-titlebar = false;
      mouse-hide-while-typing = true;
      shell-integration-features = true;
    };
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    package = null;
  };
}

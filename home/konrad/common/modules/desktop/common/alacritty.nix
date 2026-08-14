{
  lib,
  pkgs,
  ...
}:
{
  programs.tmux.extraConfig =
    # bash
    ''
      # overrides for the alacritty (host) terminal features
      set -as terminal-features ",alacritty*:RGB:hyperlinks:usstyle:focus:osc7"
    '';

  programs.alacritty = {
    enable = lib.mkDefault true;

    settings = {
      general.live_config_reload = false;

      mouse.hide_when_typing = true;
      scrolling.history = 5000;

      window = {
        blur = true;
        dynamic_padding = false;
        dynamic_title = true;
        padding = {
          x = 6;
          y = 6;
        };
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "option_as_alt" = "Both";
      };
    };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    package = null;
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.wezterm = {
    enable = lib.mkDefault true;
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    package = null;
  };

  # disable stylix's default
  xdg.configFile."wezterm/wezterm.lua".enable = false;
  xdg.configFile.wezterm =
    let
      weztermConfig = pkgs.callPackage ./config { inherit config; };
    in
    {
      source = weztermConfig;
      recursive = true;
    };

  programs.tmux.extraConfig = ''
    # overrides for the wezterm (host) terminal features
    # to print the detected ones (including set ones): tmux display -p '#{client_termfeatures}'
    set -as terminal-features ",wezterm*:RGB:hyperlinks:strikethrough:overline:sixel:usstyle"
  '';

  home = {
    file.".terminfo" = {
      enable = pkgs.stdenv.isDarwin;
      source = "${pkgs.wezterm.passthru.terminfo}/share/terminfo";
      target = ".terminfo";
      recursive = true;
    };
  };
}

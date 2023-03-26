{ config, pkgs, lib, ... }:
{
  home.sessionVariables.MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
  programs.bat = {
    enable = true;
    config = {
      # uses terminal colors according to base16 spec
      theme = "base16";
    };
  };
}

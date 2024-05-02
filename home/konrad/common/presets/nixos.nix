{ pkgs, ... }:
{
  imports = [ ./../global ];

  programs.zsh = {
    shellAliases = {
      pbcopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      pbpaste = "${pkgs.wl-clipboard}/bin/wl-paste";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
    };
  };
}

{ pkgs, ... }:
{
  imports = [
    ./../global
  ];
  programs.zsh = {
    shellAliases = {
      nixos-rebuild-switch = ''sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname -s)" switch'';
      nixos-rebuild-boot = ''sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname -s)" boot'';
      pbcopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      pbpaste = "${pkgs.wl-clipboard}/bin/wl-paste";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
    };
  };
}

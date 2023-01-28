{ pkgs, ... }:
{
  imports = [
    ./../global
  ];
  programs.zsh = {
    shellAliases = {
      nixos-rebuild-switch = ''cd ~/Code/github.com/konradmalik/dotfiles && export NIXOS_LABEL=$(${pkgs.nixos-label}/bin/nixos-label) && sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname -s)" switch && echo $NIXOS_LABEL'';
      nixos-rebuild-boot = ''cd ~/Code/github.com/konradmalik/dotfiles && export NIXOS_LABEL=$(${pkgs.nixos-label}/bin/nixos-label) && sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname -s)" boot && echo $NIXOS_LABEL'';
      pbcopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      pbpaste = "${pkgs.wl-clipboard}/bin/wl-paste";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
    };
  };
}

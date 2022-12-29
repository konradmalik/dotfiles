{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./programs/gpg-agent-systemd.nix
  ];
  programs.zsh = {
    shellAliases = {
      nixos-rebuild-switch = ''sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname)" switch'';
      nixos-rebuild-boot = ''sudo nixos-rebuild --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname)" boot'';
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      open = "xdg-open";
    };
  };
}

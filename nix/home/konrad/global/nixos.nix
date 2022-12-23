{ pkgs, ... }:
{
  imports = [
    ./programs/gpg-agent-systemd.nix
  ];
  programs.zsh = {
    shellAliases = {
      nixos-rebuild-switch = ''sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" switch'';
      nixos-rebuild-boot = ''sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" boot'';
      # pbcopy and pbpaste just like in osx
      # TODO set based on X/wayland
      # x11
      pbcopy = "xclip -selection clipboard -in";
      pbpaste = "xclip -selection clipboard -out";
      # wayland
      #pbcopy="wl-copy"
      #pbpaste="wl-paste"
      open = "xdg-open";
    };
    # initExtraFirst is not used in the global file, so we can override here
    initExtraFirst = ''
      nixos-upgrade() {
          nix-update \
          && asdf-update
      }
      nixos-clean() {
          nix-clean
      }
    '';
  };
}

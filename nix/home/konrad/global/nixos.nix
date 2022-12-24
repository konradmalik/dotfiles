{ pkgs, ... }:
{
  imports = [
    ./shared.nix
    ./programs/gpg-agent-systemd.nix
  ];
  programs.zsh = {
    shellAliases = {
      nixos-rebuild-switch = ''sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" switch'';
      nixos-rebuild-boot = ''sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" boot'';
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      open = "xdg-open";
    };
    initExtraFirst = ''
      nix-clean() {
          # current user's profile
          nix profile wipe-history --older-than 14d
          # nix store garbage collection
          nix store gc
          # system-wide
          sudo --login sh -c 'nix-collect-garbage --delete-older-than 14d'
      }

      nixos-upgrade() {
          sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" boot \
          && asdf plugin-update --all
      }
      nixos-clean() {
          nix-clean
      }
    '';
  };
}

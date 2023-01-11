{ pkgs, ... }:
{
  imports = [
    ./../common
    ./../optional/gpg-agent-systemd.nix
  ];

  programs.zsh = {
    shellAliases = {
      home-manager-switch = ''home-manager switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(whoami)@$(hostname)"'';
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      open = "xdg-open";
    };
    initExtraFirst = ''
      # update nix
      nix-update() {
          # current user's home (flakes enabled)
          home-manager switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(whoami)@$(hostname)"
          # system-wide
          sudo --login sh -c 'nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon'
      }

      # clean nix
      nix-clean() {
          # home
          home-manager expire-generations '-14 days'
          # current user's profile (flakes enabled)
          nix profile wipe-history --older-than 14d
          # nix store garbage collection
          nix store gc
          # system-wide (goes into users as well)
          sudo --login sh -c 'nix-collect-garbage --delete-older-than 14d'
      }

      if [ -f "/etc/arch-release" ]; then
          arch-upgrade() {
              yay -Syu --sudoloop \
                  --removemake \
                  --devel \
                  --nocleanmenu \
                  --nodiffmenu \
                  --noeditmenu \
                  --noupgrademenu \
              && nix-update \
              && (flatpak update || true) \
              && asdf plugin-update --all
          }
          arch-clean() {
              yay -Sc --noconfirm \
              && nix-clean
          }
      elif [ -f "/etc/debian_version" ]; then
          ubuntu-upgrade() {
              sudo apt update \
              && sudo apt upgrade -y \
              && sudo snap refresh \
              && nix-update \
              && (flatpak update || true) \
              && asdf plugin-update --all
          }
          ubuntu-clean() {
              sudo apt autoremove -y \
              && sudo apt clean \
              && sudo $HOME/.local/bin/remove-old-snaps.sh \
              && nix-clean
          }
      fi
    '';
  };
}

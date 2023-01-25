{ pkgs, ... }:
{
  imports = [
    ./../global
  ];

  programs.zsh = {
    shellAliases = {
      home-manager-switch = ''home-manager switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(whoami)@$(hostname -s)"'';
      pbcopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      pbpaste = "${pkgs.wl-clipboard}/bin/wl-paste";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
    };
    initExtra = ''
      # update nix
      nix-update() {
          # current user's home (flakes enabled)
          home-manager switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(whoami)@$(hostname)"
          # system-wide
          sudo --login sh -c 'nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon'
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

{ pkgs, ... }:
{
  imports = [
    ./programs/gpg-agent-systemd.nix
  ];

  nix = {
    package = pkgs.nix;
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  programs.zsh = {
    shellAliases = {
      home-manager-switch = ''home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"'';
      pbcopy = "wl-copy";
      pbpaste = "wl-paste";
      open = "xdg-open";
    };
    # initExtraFirst is not used in the global file, so we can override here
    initExtraFirst = ''
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
              && asdf-update
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
              && asdf-update
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

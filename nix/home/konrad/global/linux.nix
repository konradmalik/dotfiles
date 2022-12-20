{ pkgs, ... }:
{
  home.packages = with pkgs;[
    sshfs
  ];

  nix = {
    # TODO once we move to nixos, move it higher
    package = pkgs.nix;
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableSshSupport = true;
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;
    enableScDaemon = false;
    grabKeyboardAndMouse = true;
    pinentryFlavor = "tty";
    extraConfig = ''
      # timeout pinentry (s)
      pinentry-timeout 30
    '';
  };

  programs.zsh = {
    shellAliases = {
      home-manager-switch = ''home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"'';
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

{ pkgs, dotfiles, ... }:
{
  imports = [
    ./shared.nix
    ./programs/gpg-darwin.nix
  ];

  home = {
    packages =
      with pkgs; [
        coreutils
        findutils
      ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
      LIMA_INSTANCE = "devarch";
    };
  };

  programs.zsh = {
    shellAliases = {
      touchbar-restart = "sudo pkill TouchBarServer";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      darwin-rebuild-switch = ''darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(hostname)"'';
    };
    # initExtraFirst is not used in the global file, so we can override here
    initExtraFirst = ''
      # gpg agent is started via nix-darwin but GPG_TTY needs to be reset every new interactive shell
      GPG_TTY="$(tty)"
      export GPG_TTY
      gpg-connect-agent updatestartuptty /bye >/dev/null

      # update functions
      mac-upgrade() {
          brew update \
          && brew upgrade \
          && brew upgrade --cask \
          && nix-update \
          && asdf-update
      }
      mac-clean() {
          brew autoremove \
          && brew cleanup \
          && nix-clean
      }
    '';
  };
}

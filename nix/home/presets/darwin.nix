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
      darwin-rebuild-switch = ''darwin-rebuild switch --flake "git+file://$HOME/Code/github.com/konradmalik/dotfiles#$(hostname)"'';
    };
    initExtraFirst = ''
      # clean nix
      nix-clean() {
          # current user's profile (flakes enabled)
          nix profile wipe-history --older-than 14d
          # nix store garbage collection
          nix store gc
          # system-wide (goes into users as well)
          sudo --login sh -c 'nix-collect-garbage --delete-older-than 14d'
      }
    '';
  };
}

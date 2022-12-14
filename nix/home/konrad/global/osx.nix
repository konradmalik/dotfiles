{ pkgs, ... }:
{
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

  programs.zsh.shellAliases = {
    touchbar-restart = "sudo pkill TouchBarServer";
    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    darwin-rebuild-switch = ''darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(whoami)@$(hostname)"'';
  };
}


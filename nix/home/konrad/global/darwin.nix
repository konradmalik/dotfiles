{ pkgs, dotfiles, ... }:
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

    # gpg agent is managed by nix-darwin, but it's not configurable there
    # home-manager does not support gpg-agent on darwin as a service
    # but I can migrate once this is done: https://github.com/nix-community/home-manager/pull/2964
    file.".gnupg/gpg-agent.conf".text = ''
      ## 1-day timeout
      default-cache-ttl 86400
      max-cache-ttl 86400
      # disable smartcard - we don't use it
      disable-scdaemon
      # grab mouse and keyboard
      grab
      # timeout pinentry (s)
      pinentry-timeout 30
      # use tty
      pinentry-program ${pkgs.pinentry.override {enabledFlavors=["tty"];}}/bin/pinentry
    '';
  };

  programs.zsh.shellAliases = {
    touchbar-restart = "sudo pkill TouchBarServer";
    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    darwin-rebuild-switch = ''darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(whoami)@$(hostname)"'';
  };

}

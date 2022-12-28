{ pkgs, ... }:
{
  home = {
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
      pinentry-program ${pkgs.pinentry.curses}/bin/pinentry
    '';
  };
  programs.zsh = {
    initExtraFirst = ''
      # gpg agent is started via nix-darwin but GPG_TTY needs to be reset every new interactive shell
      GPG_TTY="$(tty)"
      export GPG_TTY
    '';
  };
}

{ config, pkgs, lib, osConfig, ... }:
with lib;
let
  cfg = config.konrad.programs.gpg-agent;
in
{
  options.konrad.programs.gpg-agent = {
    enable = mkEnableOption "Enables gpg-agent configuration";
  };

  config = mkIf cfg.enable {
    # gpg agent is managed by nix-darwin, but it's not configurable there
    # home-manager does not support gpg-agent on darwin as a service
    # but I can migrate once this is done: https://github.com/nix-community/home-manager/pull/2964
    assertions = [
      {
        assertion = !pkgs.stdenv.isDarwin || osConfig.programs.gnupg.agent.enable;
        message = "gpg-agent must be enabled in nix-darwin for this to work";
      }
    ];

    home.file.".gnupg/gpg-agent.conf".text = lib.optionalString pkgs.stdenv.isDarwin ''
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

    programs.zsh.initExtra = lib.optionalString pkgs.stdenv.isDarwin ''
      # gpg agent is started via nix-darwin but GPG_TTY needs to be reset every new interactive shell
      GPG_TTY="$(tty)"
      export GPG_TTY
    '';

    services.gpg-agent = {
      enable = !pkgs.stdenv.isDarwin;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableSshSupport = false;
      defaultCacheTtl = 86400;
      maxCacheTtl = 86400;
      enableScDaemon = false;
      grabKeyboardAndMouse = true;
      pinentryFlavor = "curses";
      extraConfig = ''
        # timeout pinentry (s)
        pinentry-timeout 30
      '';
    };
  };
}

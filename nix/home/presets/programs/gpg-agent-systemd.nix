{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = true;
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
}

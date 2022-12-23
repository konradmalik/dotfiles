{ pkgs, ... }:
{
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
}

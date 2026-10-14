{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    # mime defaults and $BROWSER, darwin keeps its own default browser
    setAsDefaultBrowser = pkgs.stdenv.hostPlatform.isLinux;

    # id 0, so it is the default one
    profiles.default = { };

    policies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      # bitwarden handles passwords
      PasswordManagerEnabled = false;
      ExtensionSettings = {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  stylix.targets.zen-browser.profileNames = [ "default" ];
}

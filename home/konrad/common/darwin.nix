{ pkgs, ... }:
{
  imports = [
    ./modules/base
    ./modules/desktop/common/font.nix
    ./modules/desktop/common/mpv.nix
  ];

  home = {
    packages = with pkgs; [
      # make linux people at home
      coreutils
      # make sure we use gnu versions of common commands
      findutils
      gawk
      gnugrep
      gnused
    ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
    };
  };

  programs.zsh = {
    shellAliases = {
      touchbar-restart = "sudo pkill TouchBarServer";
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
  };

  targets.darwin = {
    currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = true;
    search = "Google";
    defaults = {
      NSGlobalDomain = {
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = true;
        AppleTemperatureUnit = "Celsius";
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.dock" = {
        expose-group-apps = true;
        size-immutable = true;
        tilesize = 48;
      };
    };
  };
}

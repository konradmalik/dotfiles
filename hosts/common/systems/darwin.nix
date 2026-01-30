{
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./../modules/virtualisation/darwin.nix
    ./../modules/nix/darwin.nix
    ./../modules/home-manager.nix
    ./../modules/stylix/shared.nix

    ./../users/konrad/darwin.nix

    inputs.stylix.darwinModules.stylix
  ];

  environment = {
    etc = {
      "ssh/sshd_config.d/99-nix.conf".text = ''
        PermitRootLogin no
        PasswordAuthentication no
        ChallengeResponseAuthentication no
      '';
    };

    # zsh completion scripts
    pathsToLink = [ "/share/zsh" ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    casks = [
      "alacritty"
      "calibre"
      "firefox"
      "ghostty"
      "gimp"
      "keepingyouawake"
      "localsend"
      "microsoft-auto-update"
      "microsoft-teams"
      "netnewswire"
      "obsidian"
      "signal"
      "slack"
      "spotify"
      "syncthing-app"
    ];

    masApps = {
      "Grammarly for Safari" = 1462114288;
      Bitwarden = 1352778147;
      GoodNotes = 1444383602;
      Tailscale = 1475387142;
    };
  };

  networking = {
    # get via `networksetup -listallnetworkservices`
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    applicationFirewall = {
      enable = true;
      allowSigned = true;
      allowSignedApp = true;
    };
  };

  programs = {
    # needed to Create /etc/zshrc that loads the nix-darwin environment.
    zsh.enable = true;
  };

  # allow sudo with touchID
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = lib.mkDefault 6;

    defaults = {
      # Show battery percentage in the menu bar
      controlcenter.BatteryShowPercentage = true;
      dock = {
        autohide = true;
        expose-group-apps = true;
        magnification = false;
        show-recents = true;
        tilesize = 48;
      };
      finder = {
        CreateDesktop = true;
        ShowStatusBar = true;
        ShowPathbar = true;
      };
      trackpad = {
        Clicking = true;
      };
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        AppleMetricUnits = 1;
        NSAutomaticInlinePredictionEnabled = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      CustomUserPreferences = {
        "com.apple.Siri" = {
          "UAProfileCheckingStatus" = 0;
          "siriEnabled" = 0;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}

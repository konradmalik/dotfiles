{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ../modules/virtualisation/darwin.nix
    ../modules/nix/darwin.nix
    ./shared.nix
    ../modules/stylix/shared.nix

    ../user/darwin.nix

    inputs.stylix.darwinModules.stylix
    inputs.home-manager.darwinModules.home-manager
  ];

  services.openssh.extraConfig = ''
    PermitRootLogin no
    PasswordAuthentication no
    ChallengeResponseAuthentication no
  '';

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = lib.optionals config.home-manager.users.konrad.konrad.programs.bitwarden.enable [
      "jeanregisser/tap/bitwarden-cli-bio"
    ];
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
    ];

    masApps = {
      Bitwarden = 1352778147;
      GoodNotes = 1444383602;
      Tailscale = 1475387142;
    };
  };

  networking = {
    applicationFirewall = {
      enable = true;
      allowSigned = true;
      allowSignedApp = true;
    };
  };

  # minutes, applied to both battery and AC
  power.sleep = {
    display = 5;
    # macOS never sleeps before the display, so this means together with it
    computer = 1;
  };

  security.pam.services.sudo_local = {
    # allow sudo with touchID
    touchIdAuth = true;
    # makes touchID work inside tmux too
    reattach = true;
  };

  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = lib.mkDefault 6;

    startup.chime = false;

    defaults = {
      # 6 is CPU History
      ActivityMonitor.IconType = 6;
      # Don't show battery percentage in the menu bar
      controlcenter.BatteryShowPercentage = false;
      dock = {
        autohide = true;
        expose-group-apps = true;
        magnification = false;
        # keep spaces in a fixed order instead of most recently used
        mru-spaces = false;
        show-recents = true;
        tilesize = 48;
        # 1 disables the hot corner
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        persistent-apps = [
          "/System/Applications/Apps.app"
          "/System/Applications/Mission Control.app"
          "/Applications/Safari.app"
          "/Applications/Firefox.app"
          "/Applications/Obsidian.app"
          "/Applications/Goodnotes.app"
          "/Applications/NetNewsWire.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Reminders.app"
          "/Applications/Slack.app"
          "/Applications/Signal.app"
          "/System/Applications/Messages.app"
          "/Applications/Spotify.app"
          "/Applications/Ghostty.app"
        ];
        persistent-others = [ "${config.users.users.konrad.home}/Downloads" ];
      };
      finder = {
        AppleShowAllExtensions = true;
        CreateDesktop = true;
        FXEnableExtensionChangeWarning = false;
        # search the current folder
        FXDefaultSearchScope = "SCcf";
        # list view
        FXPreferredViewStyle = "Nlsv";
        ShowStatusBar = true;
        ShowPathbar = true;
      };
      LaunchServices.LSQuarantine = false;
      # 24h comes from NSGlobalDomain.AppleICUForce24HourTime
      menuExtraClock = {
        # 1 is always
        ShowDate = 1;
        ShowDayOfWeek = true;
      };
      screencapture.target = "clipboard";
      WindowManager.EnableTiledWindowMargins = false;
      trackpad = {
        Clicking = true;
      };
      loginwindow = {
        GuestEnabled = false;
        DisableConsoleAccess = true;
      };
      NSGlobalDomain = {
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.enableSecondaryClick" = true;
        AppleMetricUnits = 1;
        InitialKeyRepeat = 30;
        KeyRepeat = 2;
        NSDocumentSaveNewDocumentsToCloud = false;
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

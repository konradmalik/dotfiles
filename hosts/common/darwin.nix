{ lib, ... }:
{
  imports = [
    ./modules/docker/darwin.nix
    ./modules/nix/darwin.nix
    ./modules/home-manager.nix

    ./users/konrad/darwin.nix
  ];

  # packages installed in system profile
  environment = {
    pathsToLink = [
      "Applications"
      "/bin"
      "/lib"
      "/man"
      "/share"
    ];
    etc = {
      "ssh/sshd_config.d/99-nix.conf".text = ''
        PermitRootLogin no
        PasswordAuthentication no
        ChallengeResponseAuthentication no
      '';
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [ "lima" ];
    casks = [
      "alacritty"
      "calibre"
      "firefox"
      "gimp"
      "keepingyouawake"
      "microsoft-auto-update"
      "microsoft-office"
      "microsoft-teams"
      "netnewswire"
      "obsidian"
      "signal"
      "slack"
      "spotify"
      "syncthing"
      "zoom"
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
  };

  programs = {
    # needed to Create /etc/zshrc that loads the nix-darwin environment.
    zsh.enable = true;
  };

  # allow sudo with touchID
  security.pam.enableSudoTouchIdAuth = true;

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = lib.mkDefault 4;

    defaults = {
      dock = {
        show-recents = true;
      };
      finder = {
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
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}

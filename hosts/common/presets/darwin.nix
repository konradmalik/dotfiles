{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager

    ./../global/nix/darwin.nix
    ./../global/home-manager.nix

    ./../users/konrad/darwin.nix
  ];

  # packages installed in system profile
  environment = {
    systemPackages = with pkgs; [
      darwin-zsh-completions
      unstable.lima-bin
      # only to provide tmux-256color terminfo
      # until macos ships with ncurses 6
      ncurses
    ];
    pathsToLink = [ "Applications" "/bin" "/lib" "/man" "/share" ];
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
    casks =
      [
        "alacritty"
        "backblaze"
        "calibre"
        "discord"
        "drawio"
        "firefox"
        "gimp"
        "grammarly"
        "keepingyouawake"
        "microsoft-office"
        "microsoft-teams"
        "netnewswire"
        "nuclino"
        "obsidian"
        "signal"
        "slack"
        "spotify"
        "syncthing"
        "telegram"
        "whatsapp"
        "zoom"
      ];

    masApps = {
      "Grammarly for Safari" = 1462114288;
      Bitwarden = 1352778147;
      # get's reinstalled every single time
      # bugs in masApps, confused with iOS version
      GoodNotes = 1444383602;
      Pocket = 568494494;
      Tailscale = 1475387142;
    };
  };

  networking = {
    # get via `networksetup -listallnetworkservices`
    knownNetworkServices = [
      "Wi-Fi"
    ];
    dns = [ "1.1.1.1" "1.0.0.1" ];
  };

  programs = {
    # needed to Create /etc/zshrc that loads the nix-darwin environment.
    zsh.enable = true;
    # as of now, no way to enable gpg-agent through home-manager for darwin
    # but see home-manager comment, we can disable this in the future
    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
    };
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
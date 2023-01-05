{ config, pkgs, username, ... }:
{
  imports = [
    ./programs/nix/darwin.nix
  ];

  # packages installed in system profile
  environment = {
    systemPackages = with pkgs; [
      darwin-zsh-completions
      docker-client
      lima
      # only to provide tmux-256color terminfo
      # until macos ships with newer ncurses
      ncurses
    ];
    pathsToLink = [ "/share" "/bin" "/Applications" ];
    etc = {
      "ssh/sshd_config.d/99-nix.conf".text = ''
        PermitRootLogin no
        PasswordAuthentication no
        ChallengeResponseAuthentication no
        # TODO this won't work, see: https://github.com/NixOS/nixpkgs/issues/94653
        #AuthorizedKeysCommand /usr/local/bin/ssh-key-dir %u
        AuthorizedKeysCommandUser root
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
    taps = [
      "homebrew/cask"
    ];
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
        "telegram"
        "vlc"
        "zoom"
      ];

    masApps = {
      Bitwarden = 1352778147;
      "GoodNotes 5" = 1444383602;
      Pocket = 568494494;
      Tailscale = 1475387142;
      Wireguard = 1451685025;
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

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;

    defaults = {
      dock = {
        tilesize = 48;
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

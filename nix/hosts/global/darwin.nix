{ config, pkgs, ... }:
{
  imports = [
    ./programs/nix.nix
  ];

  services.nix-daemon.enable = true;

  # packages installed in system profile
  environment = {
    systemPackages = with pkgs; [
      darwin-zsh-completions
      lima
      slack
      # only to provide tmux-256color terminfo
      # until macos ships with newer ncurses
      ncurses
    ];
    pathsToLink = [ "/share/zsh" ];
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
    casks =
      [
        "calibre"
        "discord"
        "drawio"
        "firefox"
        "gimp"
        "grammarly"
        "keepingyouawake"
        "microsoft-teams"
        "netnewswire"
        "obsidian"
        "signal"
        "spotify"
        "telegram"
        "vlc"
      ];

    masApps = {
      Bitwarden = 1352778147;
      "GoodNotes 5" = 1444383602;
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
      enableSSHSupport = true;
    };
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
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}

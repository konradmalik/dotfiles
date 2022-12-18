{ config, pkgs, ... }:
{
  # packages installed in system profile
  environment = {
    systemPackages = with pkgs; [
      lima
      slack
      darwin-zsh-completions
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

  nix = {
    settings = {
      auto-optimise-store = true;
      min-free = 107374182400; # 100GB
      max-free = 214748364800; # 200GB
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
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

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

  programs = {
    # needed to Create /etc/zshrc that loads the nix-darwin environment.
    zsh.enable = true;
    gnupg.agent.enable = true;
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

{ config, pkgs, ... }: {
  # packages installed in system profile
  environment = {
    systemPackages = [
      pkgs.unstable.lima
      pkgs.unstable.slack
    ];
    pathsToLink = [ "/share/zsh" ];
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

  networking.hostName = "mbp13";

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

  programs = {
    # needed to Create /etc/zshrc that loads the nix-darwin environment.
    zsh.enable = true;
  };


  users.users.konrad = {
    name = "konrad";
    home = "/Users/konrad";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

{ config, pkgs, ... }:
{
  imports = [
    ./font.nix
    ./gtk.nix
    ./qt.nix
  ];

  xdg.mimeApps.enable = true;

  home = {
    sessionVariables = {
      BROWSER = "firefox";
      TERMINAL = "alacritty";
    };
    packages = with pkgs; [
      bitwarden
      unstable.discord
      firefox
      obsidian
      unstable.signal-desktop
      unstable.slack
      unstable.spotify
      unstable.teams
      unstable.tdesktop
      vlc
      zathura
    ];
  };

  konrad.wallpaper = "${pkgs.dotfiles}/wallpapers/bishal-mishra-SnDgEdmHJKg-unsplash.jpg";
}

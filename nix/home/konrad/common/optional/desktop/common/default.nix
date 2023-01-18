{ config, pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./font.nix
    ./gtk.nix
    ./qt.nix
  ];

  xdg.mimeApps.enable = true;

  home = {
    packages = with pkgs; [
      bitwarden
      unstable.discord
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

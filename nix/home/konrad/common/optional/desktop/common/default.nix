{ config, pkgs, outputs, ... }:
{
  imports = [
    ./firefox.nix
    ./font.nix
    ./gnome-keyring.nix
    ./gtk.nix
    ./mpv.nix
    ./qt.nix
  ];

  xdg.mimeApps.enable = true;
  # silently override mimeapps
  xdg.configFile."mimeapps.list".force = true;

  home = {
    packages = with pkgs; [
      bitwarden
      unstable.discord
      unstable.obsidian
      unstable.signal-desktop
      unstable.slack
      unstable.spotify
      unstable.teams
      unstable.tdesktop
      # for xdg-open in 'gx' in vim for example
      xdg-utils
      zathura
    ];
  };

  konrad.wallpaper = "${outputs.lib.dotfiles}/wallpapers/bishal-mishra.jpg";
}

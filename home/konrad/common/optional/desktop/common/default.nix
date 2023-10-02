{ config, pkgs, customArgs, ... }:
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
      calibre
      discord
      obsidian
      signal-desktop
      slack
      spotify
      tdesktop
      # for xdg-open in 'gx' in vim for example
      xdg-utils
      zathura
    ];
  };

  konrad.wallpaper = "${customArgs.dotfiles}/wallpapers/bishal-mishra.jpg";
}

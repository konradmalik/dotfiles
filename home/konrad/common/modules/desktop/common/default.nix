{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./hidden.nix
    ./firefox.nix
    ./gtk.nix
    ./imv.nix
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
      obsidian
      signal-desktop
      slack
      spotify
      # for xdg-open in 'gx' in vim for example
      xdg-utils
      zathura
    ];
  };
}

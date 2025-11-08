{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./audio.nix
    ./ghostty.nix
    ./hidden.nix
    ./firefox.nix
    ./imv.nix
    ./mpv.nix
    ./wezterm
  ];

  xdg.mimeApps.enable = true;
  # silently override mimeapps
  xdg.configFile."mimeapps.list".force = true;

  home = {
    packages = with pkgs; [
      bitwarden-desktop
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

  gtk.enable = true;
  qt.enable = true;
}

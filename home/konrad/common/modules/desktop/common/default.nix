{ pkgs, customArgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./ghostty.nix
    ./firefox.nix
    ./font.nix
    ./gnome-keyring.nix
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

  konrad.wallpaper = "${customArgs.files}/wallpapers/bishal-mishra.jpg";
}

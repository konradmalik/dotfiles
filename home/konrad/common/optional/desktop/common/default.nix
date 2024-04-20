{ pkgs, customArgs, ... }:
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
      # TODO go back to unstable once https://github.com/NixOS/nixpkgs/issues/305577
      stable.calibre
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

  konrad.wallpaper = "${customArgs.files}/wallpapers/bishal-mishra.jpg";
}

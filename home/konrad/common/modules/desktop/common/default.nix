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
  ];

  xdg.mimeApps.enable = true;
  # silently override mimeapps
  xdg.configFile."mimeapps.list".force = true;

  home = {
    packages = with pkgs; [
      bitwarden-desktop
      # TODO until fix lands in nixos-unstable
      (builtins.getFlake "github:NixOS/nixpkgs/c72d8b90a6c97b239c3ae16a54e05840dea7a59d")
      .legacyPackages.${pkgs.system}.calibre
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

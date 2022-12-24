{ pkgs, ... }:
{
  users.users.konrad.packages = with pkgs; [
    bitwarden
    caffeine-ng
    discord
    firefox
    obsidian
    signal-desktop
    slack
    spotify
    teams
    tdesktop
    wl-clipboard
    wl-clipboard-x11
  ];
}

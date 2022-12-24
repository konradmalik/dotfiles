{ pkgs, ... }:
{
  users.users.konrad.packages = with pkgs; [
    bitwarden
    caffeine-ng
    firefox
    slack
    spotify
    teams
    wl-clipboard
    wl-clipboard-x11
  ];
}

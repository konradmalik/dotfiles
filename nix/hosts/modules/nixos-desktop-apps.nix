{ pkgs, username, ... }:
{
  users.users.${username}.packages = with pkgs; [
    alacritty
    bitwarden
    discord
    firefox
    obsidian
    signal-desktop
    slack
    spotify
    teams
    tdesktop
    zathura
  ];
}

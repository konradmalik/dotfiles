{ pkgs, username, ... }:
{
  users.users.${username}.packages = with pkgs; [
    bitwarden
    discord
    firefox
    obsidian
    signal-desktop
    slack
    spotify
    teams
    tdesktop
  ];
}

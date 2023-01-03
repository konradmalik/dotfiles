{ pkgs, username, ... }:
{
  users.users.${username}.packages = with pkgs; [
    alacritty
    bitwarden
    unstable.discord
    firefox
    obsidian
    unstable.signal-desktop
    unstable.slack
    unstable.spotify
    unstable.teams
    unstable.tdesktop
    vlc
    zathura
  ];
}

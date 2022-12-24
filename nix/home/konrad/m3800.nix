{ config, pkgs, lib, ... }:
{
  imports = [
    ./global/nixos.nix
    ./layers/gui.nix
  ];

  # Disable gnome-keyring ssh-agent
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';
  # and prevent clobbering SSH_AUTH_SOCK by gnome
  home.sessionVariables.GSM_SKIP_SSH_AGENT_WORKAROUND = "1";

  home = {
    username = "konrad";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

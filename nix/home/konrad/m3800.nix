{ config, pkgs, lib, ... }:
{
  imports = [
    ./global
    ./global/nixos.nix
    ./global/gui.nix
  ];

  # Disable gnome-keyring ssh-agent
  xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
    ${lib.fileContents "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
    Hidden=true
  '';

  home = {
    username = "konrad";
    homeDirectory = "/home/${config.home.username}";
    # Prevent clobbering SSH_AUTH_SOCK
    sessionVariables.GSM_SKIP_SSH_AGENT_WORKAROUND = "1";
  };

  programs.alacritty.settings.font.size = 13.0;
}

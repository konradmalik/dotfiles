{ config, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  konrad.programs.desktop.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty.fontSize = 13.0;
}

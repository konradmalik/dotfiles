{ config, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
    ./modules/ssh-egress.nix
    ./modules/sway.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  konrad.programs.alacritty.fontSize = 13.0;
}

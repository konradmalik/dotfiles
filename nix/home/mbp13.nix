{ config, lib, username, ... }:

{
  imports = [
    ./presets/darwin.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${config.home.username}";
  };

  konrad.programs.desktop.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty.fontSize = 16.0;
}

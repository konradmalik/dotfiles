{ config, lib, username, ... }:

{
  imports = [
    ./presets/darwin.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${config.home.username}";
  };

  konrad.programs.alacritty.fontSize = 16.0;
}

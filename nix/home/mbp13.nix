{ config, username, ... }:

{
  imports = [
    ./presets/darwin.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 16.0;
}
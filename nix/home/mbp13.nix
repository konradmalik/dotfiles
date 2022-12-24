{ config, username, ... }:

{
  imports = [
    ./global/darwin.nix
    ./layers/gui.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 16.0;
}

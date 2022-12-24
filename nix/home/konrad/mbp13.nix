{ config, ... }:

{
  imports = [
    ./global/darwin.nix
    ./layers/gui.nix
  ];

  home = {
    username = "konrad";
    homeDirectory = "/Users/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 16.0;
}

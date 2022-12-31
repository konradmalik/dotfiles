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

  xdg.configFile. "alacritty/alacritty.yml".text =
    lib.mkAfter "  size: 16.0";
}

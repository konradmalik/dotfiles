{ config, lib, username, ... }:
{
  imports = [
    ./presets/nixos.nix
    ./modules/sway.nix
    ./modules/desktop.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  xdg.configFile. "alacritty/alacritty.yml".text =
    lib.mkAfter ''
      font:
        size: 13.0
    '';
}

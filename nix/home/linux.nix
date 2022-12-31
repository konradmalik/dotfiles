{ config, lib, username, ... }:
{
  imports = [
    ./presets/nonnixos.nix
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

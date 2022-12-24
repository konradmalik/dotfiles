{ config, username,... }:
{
  imports = [
    ./global/nonnixos.nix
    ./layers/gui.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${config.home.username}";
  };

  programs.alacritty.settings.font.size = 13.0;
}

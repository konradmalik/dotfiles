{ config, dotfiles, ... }:
{
  imports = [
    ./global
    # cannot use it, missing dependencies for non-nixos hosts
    #./global/gui.nix
  ];
  home = {
    username = "konrad";
    homeDirectory = "/home/${config.home.username}";
  };

  # alacritty
  xdg.configFile."alacritty/alacritty.yml".text =
    builtins.replaceStrings
      [ "~/.config/alacritty" "local.yml" ]
      [ "${dotfiles}/alacritty" "ubuntu.yml" ]
      (builtins.readFile "${dotfiles}/alacritty/alacritty.yml");
}

{
  imports = [ ../modules/home-manager.nix ];

  # zsh completion scripts
  environment.pathsToLink = [ "/share/zsh" ];

  programs.zsh.enable = true;
}

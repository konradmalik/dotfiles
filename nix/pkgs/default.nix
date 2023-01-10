{ pkgs }:
{
  darwin-zsh-completions = pkgs.callPackage ./darwin-zsh-completions.nix { };
  dotfiles = ../../files;
  yaml-utils = pkgs.callPackage ./yaml.nix { };
}

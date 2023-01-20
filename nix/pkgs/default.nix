{ pkgs }:
{
  darwin-zsh-completions = pkgs.callPackage ./darwin-zsh-completions.nix { };
  dotfiles = pkgs.callPackage ./dotfiles.nix { };
}

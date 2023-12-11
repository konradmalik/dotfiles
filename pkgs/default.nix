{ pkgs }:
{
  darwin-zsh-completions = pkgs.callPackage ./darwin-zsh-completions.nix { };
  rfv = pkgs.callPackage ./rfv { };
}

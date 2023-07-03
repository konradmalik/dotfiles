{ pkgs }:
{
  darwin-zsh-completions = pkgs.callPackage ./darwin-zsh-completions.nix { };
  rfv = pkgs.callPackage ./rfv { };
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer { };
  tmux-switcher = pkgs.callPackage ./tmux-switcher { };
  tmux-windowizer = pkgs.callPackage ./tmux-windowizer { };
}

{ pkgs }:
{
  darwin-zsh-completions = pkgs.callPackage ./darwin-zsh-completions.nix { };
  remove-old-snaps = pkgs.callPackage ./remove-old-snaps { };
  rfv = pkgs.callPackage ./rfv { };
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer { };
  tmux-switcher = pkgs.callPackage ./tmux-switcher { };
  tmux-windowizer = pkgs.callPackage ./tmux-windowizer { };
}

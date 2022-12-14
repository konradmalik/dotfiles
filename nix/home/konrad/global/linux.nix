{ pkgs, ... }:
{
  home.packages = with pkgs;[
    sshfs
  ];

  programs.zsh.shellAliases = {
    home-manager-switch = ''home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"'';
    # pbcopy and pbpaste just like in osx
    # TODO set based on X/wayland
    # x11
    pbcopy = "xclip -selection clipboard -in";
    pbpaste = "xclip -selection clipboard -out";
    # wayland
    #pbcopy="wl-copy"
    #pbpaste="wl-paste"
    open = "xdg-open";
  };
}


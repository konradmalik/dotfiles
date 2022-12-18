{ pkgs, ... }:
{
  home.packages = with pkgs;[
    sshfs
  ];

  nix = {
    # TODO once we move to nixos, move it higher
    package = pkgs.nix;
    system-features = [ "kvm" ];
  };

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableSshSupport = false;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    enableScDaemon = false;
    grabKeyboardAndMouse = true;
    pinentryFlavor = "tty";
    extraConfig = ''
      # timeout pinentry (s)
      pinentry-timeout 30
    '';
  };

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


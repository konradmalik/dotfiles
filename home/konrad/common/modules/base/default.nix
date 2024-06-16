{ config, lib, ... }:
{
  imports = [
    ./atuin.nix
    ./bat.nix
    ./bottom.nix
    ./colors.nix
    ./direnv.nix
    ./earthly.nix
    ./fzf.nix
    ./git.nix
    ./glow.nix
    ./gpg.nix
    ./k9s.nix
    ./neovim.nix
    ./nix-index.nix
    ./packages.nix
    ./readline.nix
    ./rtorrent.nix
    ./shells
    ./sops.nix
    ./ssh-keys.nix
    ./starship.nix
    ./tealdeer.nix
  ] ++ builtins.attrValues (import ./../../options);

  konrad.programs = {
    tmux.enable = true;
    ssh-egress.enable = true;
  };

  programs.home-manager.enable = true;

  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.11";

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      PAGER = "less -FirSwX";
      GOPATH = "${config.home.homeDirectory}/.go";
      GOBIN = "${config.home.homeDirectory}/.go/bin";
    };

    sessionPath = [
      "$GOBIN"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}

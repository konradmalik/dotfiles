{ config, lib, pkgs, ... }:

let
  # custom tmux plugins
  tmuxSuspend = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-suspend";
      version = "main";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-suspend";
          rev = "f7d59c0482d949013851722bb7de53c0158936db";
          sha256 = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
        };
    };
  tmuxModeIndicator = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-mode-indicator";
      version = "main";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-mode-indicator";
          rev = "11520829210a34dc9c7e5be9dead152eaf3a4423";
          sha256 = "sha256-hlhBKC6UzkpUrCanJehs2FxK5SoYBoiGiioXdx6trC4=";
        };
    };

  publicDotfiles = ./../../../../files;
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    tmux = {
      enable = true;
      package = pkgs.unstable.tmux;
      sensibleOnTop = false;
      extraConfig = lib.strings.concatStringsSep "\n" [
        (builtins.readFile "${publicDotfiles}/tmux/.config/konrad.conf")
        (builtins.readFile "${publicDotfiles}/tmux/.config/catppuccin.conf")
      ];
      plugins = [
        tmuxSuspend
        tmuxModeIndicator
      ];
    };
  };
}


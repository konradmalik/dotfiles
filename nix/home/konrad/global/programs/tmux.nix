{ config, lib, pkgs, dotfiles, dotfiles-private, ... }:
let
  tmux-suspend = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-suspend";
      version = "2021-06-07";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-suspend";
          rev = "f7d59c0482d949013851722bb7de53c0158936db";
          sha256 = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
        };
    };
  tmux-mode-indicator = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-mode-indicator";
      version = "2021-10-01";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-mode-indicator";
          rev = "11520829210a34dc9c7e5be9dead152eaf3a4423";
          sha256 = "sha256-hlhBKC6UzkpUrCanJehs2FxK5SoYBoiGiioXdx6trC4=";
        };
    };
in
{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    # tmux-256color is the proper one to enable italics
    # just ensure you have that terminfo, newer ncurses provide it
    # Macos does not have it but we fix that by installing ncurses through nix-darwin
    # screen-256color works properly everywhere but does not have italics
    terminal = "tmux-256color";
    keyMode = "vi";
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 50000;
    extraConfig = lib.strings.concatStringsSep "\n" [
      (builtins.readFile "${dotfiles}/tmux/konrad.conf")
      (builtins.readFile "${dotfiles}/tmux/catppuccin.conf")
    ];
    plugins = [
      tmux-suspend
      tmux-mode-indicator
    ];
  };

  programs.fzf.tmux.enableShellIntegration = true;
}

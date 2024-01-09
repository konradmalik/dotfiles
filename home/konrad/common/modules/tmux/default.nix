{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.tmux;
  tmuxTextProcessor = pkgs.callPackage ./text_processor.nix { };
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer { };
  tmux-switcher = pkgs.callPackage ./tmux-switcher { };
  tmux-windowizer = pkgs.callPackage ./tmux-windowizer { };
  baseConfig = pkgs.callPackage ./config.nix { inherit config tmuxTextProcessor tmux-switcher; };
  themeConfig = import ./theme.nix { inherit (cfg) colorscheme; };
in
{
  options.konrad.programs.tmux = {
    enable = mkEnableOption "Enables personalized tmux through home-manager";

    colorscheme = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = config.colorscheme;
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "config.colorscheme";
    };
  };

  config = mkIf cfg.enable
    {
      programs.tmux = {
        enable = true;
        aggressiveResize = true;
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
        extraConfig = lib.concatStringsSep "\n" [ baseConfig themeConfig ];
        plugins = [ ];
      };

      programs.git.ignores = [
        ".tmux.sh"
      ];

      programs.fzf.tmux.enableShellIntegration = true;

      programs.zsh = {
        initExtra = ''
          # tmux baby
          # (this cannot be a zsh widget unfortunately, tmux attach can only attach to a terminal,
          # but zsh widgets do not allocate/reuse current terminal)
          __txs() { ${tmux-sessionizer}/bin/tmux-sessionizer }
          bindkey -s '^F' '^u__txs^M'

          # fix for ssh socket and display env var in tmux
          # run after attaching to a remote session for a 2+ time if you need it
          tmux-refresh() {
              eval "$(tmux show-environment -s SSH_AUTH_SOCK)"
              eval "$(tmux show-environment -s DISPLAY)"
          }
        '';
        shellAliases = {
          txs = "${tmux-sessionizer}/bin/tmux-sessionizer";
          txw = "${tmux-windowizer}/bin/tmux-windowizer";
          txr = "${tmux-switcher}/bin/tmux-switcher";
        };
      };
    };
}

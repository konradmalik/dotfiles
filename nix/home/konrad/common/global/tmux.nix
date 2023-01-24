{ config, lib, pkgs, ... }:
let
  baseConfig = ''
    ## SENSIBLE DEFAULTS
    ## don't use the tpm plugin, it's a bit outdated
    # tmux messages are displayed for 4 seconds
    set-option -g display-time 4000
    # upgrade color and fix italics
    set -ga terminal-overrides ",-256color:Tc,alacritty:Tc"
    # focus events enabled for terminals that support them
    set-option -g focus-events on
    # super useful when using "grouped sessions" and multi-monitor setup
    set-option -g aggressive-resize on

    # Let the window to be renamed automatically when launching a process
    set-option -g automatic-rename on
    # But prevent renaming once you have manually changed it. And you can re-rename it after.
    set-option -g allow-rename off
    set-option -g set-titles on

    # renumber so that we have 1,2,3 always
    set-option -g renumber-windows on

    # Set window notifications
    set-option -g monitor-activity on
    set-option -g visual-activity off

    # vim splits
    bind-key v split-window -h
    bind-key g split-window -v

    # vim panes
    bind-key h select-pane -L
    bind-key j select-pane -D
    bind-key k select-pane -U
    bind-key l select-pane -R

    # vim pane resize
    bind-key < resize-pane -L 10
    bind-key > resize-pane -R 10
    bind-key - resize-pane -D 10
    bind-key + resize-pane -U 10

    # Setup 'v' to begin selection, just like vim
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
    bind-key -T copy-mode-vi 'V' send-keys -X select-line
    bind-key -T copy-mode-vi 'r' send-keys -X rectangle-toggle
    # Setup 'y' to yank (copy), just like VIM
    bind-key -T copy-mode-vi 'y' send-keys -X copy-selection-and-cancel
    # Setup P (capital) to paste after the prefix keys, JUST LIKE VIM
    bind P paste-buffer

    # Use m to toggle mouse mode
    unbind m
    bind-key m setw mouse

    # when nested tmux session,
    # C-a will send the prefix directly to the remote session
    # C-A clashes with C-A in neovim!
    #bind-key -n C-a send-prefix
  '';
  themeConfig =
    let
      c = config.colorscheme.colors;
    in
    ''
      # --> Catppuccin
      thm_base00="#${lib.toLower c.base00}"
      thm_base01="#${lib.toLower c.base01}"
      thm_base02="#${lib.toLower c.base02}"
      thm_base03="#${lib.toLower c.base03}"
      thm_base04="#${lib.toLower c.base04}"
      thm_base05="#${lib.toLower c.base05}"
      thm_base06="#${lib.toLower c.base06}"
      thm_base07="#${lib.toLower c.base07}"
      thm_base08="#${lib.toLower c.base08}"
      thm_base09="#${lib.toLower c.base09}"
      thm_base0A="#${lib.toLower c.base0A}"
      thm_base0B="#${lib.toLower c.base0B}"
      thm_base0C="#${lib.toLower c.base0C}"
      thm_base0D="#${lib.toLower c.base0D}"
      thm_base0E="#${lib.toLower c.base0E}"
      thm_base0F="#${lib.toLower c.base0F}"

      # ----------------------------=== Theme ===--------------------------
      # Catppuccin layout

      # status
      set -g status-position bottom
      set -g status "on"
      set -g status-justify "left"
      set -g status-left-length "100"
      set -g status-right-length "100"
      set -g status-style "fg=''${thm_base04},bg=''${thm_base01}"

      # messages
      set -g message-style fg="''${thm_base05}",bg="''${thm_base01}",align="centre"
      set -g message-command-style fg="''${thm_base05}",bg="''${thm_base01}",align="centre"

      # panes
      set -g pane-border-style fg="''${thm_base01}"
      set -g pane-active-border-style fg="''${thm_base02}"

      # windows
      setw -g window-status-activity-style fg="''${thm_base04}",bg="default",none
      setw -g window-status-separator ""
      setw -g window-status-style fg="''${thm_base0A}",bg="default",none

      # --------=== Statusline
      set -g status-left ""
      set -g status-right "#{?client_prefix,#[bg=$thm_base0F],#[bg=$thm_base0C]}#[fg=$thm_base01]  #[fg=$thm_base05,bg=$thm_base01] #S "

      # current_dir
      setw -g window-status-current-format "#[fg=$thm_base01,bg=$thm_base0C] #I #[fg=$thm_base0C,bg=$thm_base03] #W #{?window_zoomed_flag, ,}"
      setw -g window-status-format "#[fg=$thm_base01,bg=$thm_base07] #I #[fg=$thm_base07,bg=$thm_base01] #W #{?window_zoomed_flag, ,}"

      # --------=== Modes
      setw -g clock-mode-colour "''${thm_base0D}"
      setw -g mode-style "fg=''${thm_base02} bg=''${thm_base0F} bold"
    '';
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
    extraConfig = lib.concatStringsSep "\n" [ baseConfig themeConfig ];
    plugins = [ ];
  };

  programs.fzf.tmux.enableShellIntegration = true;

  programs.zsh.initExtra = ''
    # tmux baby
    rtxs() { ${pkgs.tmux-sessionizer}/bin/tmux-sessionizer }
    bindkey -s '^F' '^urtxs^M'

    # fix for tmux ssh socket
    fix_ssh_auth_sock() {
        # (On) reverses globbing order
        # https://unix.stackexchange.com/a/27400
        for tsock in /tmp/ssh*/agent*(On); do
            if [ -O "$tsock" ]; then
                sock=$tsock
                break
            fi
        done
        if [ -n "$sock" ]; then
            export SSH_AUTH_SOCK="$sock"
            echo "New socket: $sock"
        else
            echo "Could not find appropriate socket :("
            unset SSH_AUTH_SOCK
        fi
    }
  '';
}

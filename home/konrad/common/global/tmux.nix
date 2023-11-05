{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  tmuxTextProcessor = pkgs.writeShellScript "tmux_text_processor" ''
    program="$1"
    paneid="$2"
    currentpanepath="$3"
    capturename="$(basename $program)-$paneid"
    showandpipe="${tmux} show-buffer -b '$capturename' | $program || true; ${tmux} delete-buffer -b '$capturename'"

    ${tmux} capture-pane -J -S - -E - -b "$capturename" -t "$paneid"
    ${tmux} split-window -c "$currentpanepath" "$showandpipe"
  '';
  baseConfig = ''
    ## KONRAD's SENSIBLE DEFAULTS
    # tmux messages are displayed for 4 seconds
    set-option -g display-time 4000
    # upgrade color and fix italics
    set -ga terminal-overrides ",-256color:Tc,alacritty:Tc"
    # focus events enabled for terminals that support them
    set-option -g focus-events on

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
    # enable mouse by default, useful for resizing
    set-option -g mouse on

    # when nested tmux session,
    # C-a will send the prefix directly to the remote session
    # C-A clashes with C-A in neovim!
    #bind-key -n C-a send-prefix

    # facebook pathpicker
    bind-key F run-shell -b "${tmuxTextProcessor} '${pkgs.fpp}/bin/fpp' '#{pane_id}' '#{pane_current_path}'"

    # urlscan
    bind-key U run-shell -b "${tmuxTextProcessor} '${pkgs.urlscan}/bin/urlscan' '#{pane_id}' '#{pane_current_path}'"

    # tmux session switcher
    bind-key r run-shell -b "${pkgs.tmux-switcher}/bin/tmux-switcher"

    # toggle last window
    bind-key W last-window

    # toggle last session
    bind-key S switch-client -l
  '';
  themeConfig =
    let
      c = config.colorscheme.colors;
    in
    ''
      # Base16 ${config.colorscheme.name}
      # Scheme author: ${config.colorscheme.author}
      # Template author: Tinted Theming: (https://github.com/tinted-theming)

      # default statusbar colors
      set-option -g status-style "fg=#${c.base04},bg=default"

      # default window title colors
      set-window-option -g window-status-style "fg=#${c.base04},bg=default"

      # active window title colors
      set-window-option -g window-status-current-style "fg=#${c.base0A},bg=default"

      # pane border
      set-option -g pane-border-style "fg=#${c.base01}"
      set-option -g pane-active-border-style "fg=#${c.base02}"

      # message text
      set-option -g message-style "fg=#${c.base05},bg=#${c.base01}"

      # pane number display
      set-option -g display-panes-active-colour "#${c.base0B}"
      set-option -g display-panes-colour "#${c.base0A}"

      # clock
      set-window-option -g clock-mode-colour "#${c.base0B}"

      # copy mode highlight
      set-window-option -g mode-style "fg=#${c.base04},bg=#${c.base02}"

      # bell
      set-window-option -g window-status-bell-style "fg=#${c.base01},bg=#${c.base08}"

      # status bar formatting
      set -g status-left "#[fg=#${c.base0D},bold]  #S "
      set -g status-right "#[fg=#${c.base06},bold]%a %Y-%m-%d 󱑒 %H:%M"
      set -g status-justify left
      set -g status-left-length 200     # increase length (from 10)
      set -g status-right-length 200    # increase length (from 10)
      set -g status-position top

      # window formatting
      set -g window-status-current-format '#[fg=#${c.base0E}][#I #W#{?window_zoomed_flag,( ),}]'
      set -g window-status-format '#[fg=#${c.base04}] #I #W '
      set -g window-status-last-style 'fg=#${c.base06},bg=#${c.base01}'
    '';
in
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

  programs.zsh.initExtra = ''
    # tmux baby
    # (this cannot be a zsh widget unfortunately, tmux attach can only attach to a terminal,
    # but zsh widgets do not allocate/reuse current terminal)
    __txs() { ${pkgs.tmux-sessionizer}/bin/tmux-sessionizer }
    bindkey -s '^F' '^u__txs^M'

    # fix for ssh socket and display env var in tmux
    # run after attaching to a remote session for a 2+ time if you need it
    tmux-refresh() {
        eval "$(tmux show-environment -s SSH_AUTH_SOCK)"
        eval "$(tmux show-environment -s DISPLAY)"
    }
  '';
}

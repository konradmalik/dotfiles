{
  tmux-switcher,
  tmuxTextProcessor,
  pkgs,
}:
''
  ## KONRAD's SENSIBLE DEFAULTS
  # tmux messages are displayed for 4 seconds
  set-option -g display-time 4000

  # overrides for the host terminal
  # RGB color
  set -as terminal-features ",*:RGB"
  # colored undercurls
  # https://ryantravitz.com/blog/2023-02-18-pull-of-the-undercurl/
  # https://github.com/tmux/tmux/issues/3444
  # https://github.com/alacritty/alacritty/pull/6803
  set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

  # focus events enabled for terminals that support them
  set-option -g focus-events on
  # refresh interval
  set-option -g status-interval 60

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

  # vi-like copy mode
  set-window-option -g mode-keys vi
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

  # facebook pathpicker
  bind-key F run-shell -b "${tmuxTextProcessor} '${pkgs.fpp}/bin/fpp -nfc' '#{pane_id}' '#{pane_current_path}'"

  # tmux session switcher
  bind-key r run-shell -b "${tmux-switcher}/bin/tmux-switcher"

  # toggle last window
  bind-key W last-window

  # toggle last session
  bind-key S switch-client -l
''

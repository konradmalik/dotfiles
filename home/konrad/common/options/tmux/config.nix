{
  tmux-sessionizer,
  tmux-switcher,
  tmuxTextProcessor,
  pkgs,
  lib,
}:
''
  ## KONRAD's SENSIBLE DEFAULTS
  # tmux messages are displayed for 4 seconds
  set-option -g display-time 4000

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

  # easier switching between next/prev window
  bind-key C-p previous-window
  bind-key C-n next-window

  # Use m to toggle mouse mode
  unbind m
  bind-key m setw mouse
  # enable mouse by default, useful for resizing
  set-option -g mouse on

  # tmux sessionizer
  bind-key C-o run-shell -b "${tmux-sessionizer}/bin/tms"

  # facebook pathpicker
  bind-key F run-shell -b "${tmuxTextProcessor} '${lib.getExe pkgs.fpp} -nfc' '#{pane_id}' '#{pane_current_path}'"

  # tmux session switcher
  bind-key C-s run-shell -b "${tmux-switcher}/bin/tmr"

  # toggle last window
  bind-key W last-window

  # toggle last session
  bind-key S switch-client -l
''

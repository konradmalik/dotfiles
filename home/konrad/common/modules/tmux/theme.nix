{ colorscheme }:
let
  c = colorscheme.colors;
in
''
  # Base16 ${colorscheme.name}
  # Scheme author: ${colorscheme.author}
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
''

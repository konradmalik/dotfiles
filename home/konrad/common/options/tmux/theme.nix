{ config, ... }:
let
  c = config.lib.stylix.colors;
in
# tmux
''
  set -g status-style "fg=#${c.base04},bg=default"
  set -g window-status-style "bg=default"
  set -g window-status-current-style "fg=#${c.base0A},bg=default"
  set -g window-status-last-style "bg=default"
  set -g window-status-bell-style "fg=#${c.base01},bg=#${c.base09}"
  set -g window-status-activity-style "fg=#${c.base09}"

  set -g status-left "#[fg=#${c.base0D},bold]  #S "
  set -g status-right "#[fg=#${c.base0E}] #H"
  set -g status-justify left
  set -g status-left-length 200     # increase length (from 10)
  set -g status-right-length 200    # increase length (from 10)
  set -g status-position top

  set -g window-status-current-format '#[fg=#${c.base0E}][#I #W#{?window_zoomed_flag,( ),}]'
  set -g window-status-format ' #I #W '
''

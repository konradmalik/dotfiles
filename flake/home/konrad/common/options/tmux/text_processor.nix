{ tmux, writeShellScript, ... }:
let
  tmux' = "${tmux}/bin/tmux";
in
writeShellScript "tmux_text_processor" ''
  program="$1"
  paneid="$2"
  currentpanepath="$3"
  capturename="$(basename $program)-$paneid"
  showandpipe="${tmux'} show-buffer -b '$capturename' | $program || true; ${tmux'} delete-buffer -b '$capturename'"

  ${tmux'} capture-pane -J -S - -E - -b "$capturename" -t "$paneid"
  ${tmux'} split-window -c "$currentpanepath" "$showandpipe"
''

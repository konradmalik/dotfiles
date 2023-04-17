#!/usr/bin/env bash

set -e

active_sessions=$(tmux ls 2>/dev/null || echo "no sessions")
export active_sessions
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . --type d --min-depth 1 --max-depth 4 ~/Code | fzf --preview 'echo "Selected session: $(basename {} | tr . _)\nActive sessions:\n$active_sessions"')
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    # if not such session, create
    # use $() to avoid SHLVL increase
    $(tmux new-session -ds "$selected_name" -c "$selected")
fi

# at this point we have a session, now figure out how to connect

if [[ -z $TMUX ]]; then
    # not in tmux, just attach
    tmux attach -t "$selected_name"
else
    # inside tmux, just switch
    tmux switch-client -t "$selected_name"
fi

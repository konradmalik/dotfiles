#!/usr/bin/env bash

tmux_script_name=".tmux.sh"

cmd='echo "Selected session: $(basename {} | tr . _)\nActive sessions:\n$(tmux list-sessions 2>/dev/null || echo "no active sessions")"'
if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . --type d --min-depth 1 --max-depth 3 ~/Code | fzf-tmux -p 80% -- --preview="$cmd")
fi

if [[ -z $selected ]]; then
    # nothing selected
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    # if not such session, create
    # use $() to avoid SHLVL increase
    $(tmux new-session -ds "$selected_name" -c "$selected")

    # try to execute script if exists
    if [ -f "$selected/$tmux_script_name" ]; then
        "$selected/$tmux_script_name" "$selected_name"
    fi
fi

# at this point we have a session, now figure out how to connect

if [[ -z $TMUX ]]; then
    # not in tmux, just attach
    tmux attach -t "$selected_name"
else
    # inside tmux, just switch
    tmux switch-client -t "$selected_name"
fi

#!/usr/bin/env bash

active_sessions=$(tmux list-sessions 2>/dev/null || echo "")
if [[ -z $active_sessions ]]; then
    echo "no active sessions"
    exit 0
fi

selected=$(echo "$active_sessions" | fzf-tmux -p | cut -d ":" -f1)
if [[ -z $selected ]]; then
    # nothing selected
    exit 0
fi

# at this point we have a session, now figure out how to connect

if [[ -z $TMUX ]]; then
    # not in tmux, just attach
    tmux attach -t "$selected"
else
    # inside tmux, just switch
    tmux switch-client -t "$selected"
fi

#!/usr/bin/env bash

branch_name=$(basename "$1")
session_name=$(tmux display-message -p "#S")
window_name=$(echo "$branch_name" | tr "./" "__")

if [ $# -lt 2 ]; then
    echo "too few arguments; provide at least: <window_name> *<cmd>"
    exit 1
fi

# we dont want to support this script while outside tmux
if [[ -z $TMUX ]]; then
    # not in tmux
    echo "not inside tmux"
    exit 1
fi

# check if tmux has a window
if ! tmux has-session -t "$session_name:$window_name" 2>/dev/null; then
    tmux neww -dn "$window_name"
fi

shift
tmux send-keys -t "$session_name:$window_name" "$*
"

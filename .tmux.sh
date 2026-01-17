#!/usr/bin/env bash

set -e

session=$1

tmux new-window -t "$session" -c "#{pane_current_path}"
tmux previous-window -t "$session"
tmux send-keys -t "$session" "vim flake.nix" Enter

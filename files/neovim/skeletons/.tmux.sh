#!/usr/bin/env bash
# CHANGEME: this is skeleton file from neovim

set -e

session=$1

tmux send-keys -t "$session" "vim flake.nix" Enter
tmux new-window -t "$session" -c "#{pane_current_path}"
tmux previous-window -t "$session"

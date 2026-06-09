#!/usr/bin/env bash

set -e

session=$1

dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

tmux new-window -t "$session" -c "$dir"
tmux previous-window -t "$session"
tmux send-keys -t "$session" "nvim flake.nix" Enter

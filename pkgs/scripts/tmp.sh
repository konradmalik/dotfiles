#!/usr/bin/env bash

set -euo pipefail

case "$1" in
help | h | -h | --help)
    echo "use 'tmp view' to see tmp folders; without arguments it'll create a new one"
    ;;
view | list | ls)
    cd /tmp/workspaces && cd "$(ls --sort=modified --reverse | fzf --preview 'ls -A {}')" && return 0
    ;;
*)
    r="/tmp/workspaces/$(xxd -l3 -ps /dev/urandom)"
    mkdir -p "$r" && pushd "$r"
    ;;
esac

#!/bin/sh
set -eu

if hash pbcopy 2>/dev/null; then
    exec pbcopy
elif hash wl-copy 2>/dev/null; then
    exec wl-copy
elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard
else
    rm -f /tmp/clipboard 2>/dev/null
    if [ $# -eq 0 ]; then
        cat >/tmp/clipboard
    else
        cat "$1" >/tmp/clipboard
    fi
fi

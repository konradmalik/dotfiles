#!/bin/sh
set -eu

if hash pbpaste 2>/dev/null; then
    exec pbpaste
elif hash wl-paste 2>/dev/null; then
    exec wl-paste
elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard -o
elif [ -e /tmp/clipboard ]; then
    exec cat /tmp/clipboard
else
    echo ''
fi

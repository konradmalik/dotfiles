#!/bin/sh
set -eu

if hash pbpaste 2>/dev/null; then
    exec pbpaste
elif hash wl-paste 2>/dev/null; then
    exec wl-paste
elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard -o
elif [ -e "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/cbclipboard" ]; then
    # kept in sync with cbcopy
    exec cat "${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/cbclipboard"
else
    echo ''
fi

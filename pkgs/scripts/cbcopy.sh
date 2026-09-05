#!/bin/sh
set -eu

if hash pbcopy 2>/dev/null; then
    exec pbcopy
elif hash wl-copy 2>/dev/null; then
    exec wl-copy
elif hash xclip 2>/dev/null; then
    exec xclip -selection clipboard
else
    # per-user location; /tmp/clipboard is shared and pre-creatable by anyone.
    # cbpaste derives the same path.
    clipboard="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/cbclipboard"
    rm -f "$clipboard" 2>/dev/null
    if [ $# -eq 0 ]; then
        cat >"$clipboard"
    else
        cat "$1" >"$clipboard"
    fi
fi

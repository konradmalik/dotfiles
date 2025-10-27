#!/usr/bin/env bash
set -eu

BROWSER="${BROWSER:-open}"

if [ $# -eq 0 ]; then
    "$BROWSER" 'https://google.com'
else
    args="$*"
    search="${args// /+}"
    "$BROWSER" "https://google.com/search?q=$search"
fi

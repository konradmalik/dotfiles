#!/bin/sh
set -eu

port='8000'
if [ $# -eq 1 ]; then
    port="$1"
fi

python3 -m http.server "$port"

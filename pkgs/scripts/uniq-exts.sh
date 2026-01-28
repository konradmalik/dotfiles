#!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 1 ]; then
    echo >&2 "You have to provide the directory"
    exit 2
fi

wd="${1}"
cd "$wd"

fd --type f |
    sed -n 's/.*\.//p' |
    sort |
    uniq -c |
    sort -nr

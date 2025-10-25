#!/usr/bin/env bash

set -euo pipefail

wd="${1}"
if [ $# -lt 1 ]; then
    echo >&2 "You have to provide the directory"
    exit 2
fi

cd "$wd"
find . -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u

#!/usr/bin/env bash

set -euo pipefail

wd="${1:-.}"
cd "$wd"

fd --type f |
    sed -n 's/.*\.//p' |
    sort |
    uniq -c |
    sort -nr

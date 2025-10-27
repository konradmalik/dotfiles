#!/usr/bin/env bash
set -euo pipefail

path="$(mktemp | tr -d '\n')"
echo -n "$path"
echo -n "$path" | cbcopy

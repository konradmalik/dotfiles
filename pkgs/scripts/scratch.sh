#!/bin/sh
set -eu

file="$(mktemp)"
echo "Editing $file"
exec "$EDITOR" "$file"

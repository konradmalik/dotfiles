#!/usr/bin/env bash
set -e

param="$1"
if [ -z "$param" ]; then
    curl "wttr.in/?F"
else
    curl "wttr.in/''${param}?F"
fi

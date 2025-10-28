#!/usr/bin/env bash
set -euo pipefail

trap 'exit 0' SIGINT

last_value=''

while true; do
    value="$(cbpaste)"

    if [ "$last_value" != "$value" ]; then
        echo "$value"
        last_value="$value"
    fi

    sleep 0.5
done

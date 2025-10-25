#!/usr/bin/env bash
set -eo pipefail

in="$1"
if [ -z "$in" ]; then
    jwt=$(cat /dev/stdin)
else
    jwt="$1"
fi

echo "$jwt" | jc --jwt | jq

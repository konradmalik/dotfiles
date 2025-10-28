#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   remind.sh 10s "Take a break" "Stretch your legs"
#   remind.sh 120 "Tea is ready" "Go grab it"
#   remind.sh 2m "Meeting" "Join Zoom"

# Time can be:
#   - a plain number (seconds)
#   - Ns (seconds)
#   - Nm (minutes)

if [ $# -lt 2 ]; then
    echo "Usage: $0 <time> <title> [message]"
    exit 1
fi

time_spec="$1"
title="${2:-Reminder}"
message="${3:-}"

# Convert time to seconds if needed
if [[ "$time_spec" =~ ^[0-9]+$ ]]; then
    seconds=$time_spec
elif [[ "$time_spec" =~ ^([0-9]+)s$ ]]; then
    seconds="${BASH_REMATCH[1]}"
elif [[ "$time_spec" =~ ^([0-9]+)m$ ]]; then
    seconds=$((BASH_REMATCH[1] * 60))
else
    echo "Invalid time format. Use <number>, <number>s or <number>m"
    exit 1
fi

bb sh -c "sleep \"$seconds\" && notify \"$title\" \"$message\""

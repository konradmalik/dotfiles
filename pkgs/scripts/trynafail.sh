#!/bin/sh

set -u

"$@"
while [ "$?" -eq 0 ]; do
    sleep 0.5
    "$@"
done

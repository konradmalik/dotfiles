#!/bin/sh

set -u

until "$@"; do
    sleep 0.5
done

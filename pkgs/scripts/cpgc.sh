#!/usr/bin/env bash
set -euo pipefail

git rev-parse "$1" | cbcopy

#!/usr/bin/env bash
set -euo pipefail

rev="${1:-@}"
git rev-parse "$rev" | cbcopy

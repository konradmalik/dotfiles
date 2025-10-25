#!/bin/sh
set -eu

if [ ! -e flake.nix ]; then
    nix flake new -t github:konradmalik/dotfiles#default .
else
    echo "flake already exists"
fi

#!/bin/sh

set -e

if [ $# -eq 0 ]; then
    echo "No arguments supplied"
    echo "first should be repo"
    echo "optional second should be root directory"
fi

base_dir=$PWD
root=${2:-$PWD}

mkdir -p "$root"
cd "$root"

git clone "$1" ./main
cd ./main

git worktree add --detach ../work
git worktree add --detach ../review
git worktree add --detach ../scratch
git worktree add --detach ../auto

cd "$base_dir"

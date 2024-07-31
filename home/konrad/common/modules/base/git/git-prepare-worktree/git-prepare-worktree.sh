#!/bin/sh

set -e

git worktree add --detach ../work
git worktree add --detach ../review
git worktree add --detach ../scratch
git worktree add --detach ../auto

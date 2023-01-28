#!/usr/bin/env bash

today=$(date +%Y%m%d)
branch=$(git branch --show-current)
revision=$(git rev-parse --short HEAD)
if [[ $(git diff --stat) != "" ]]; then
	dirty="-dirty"
else
	dirty=""
fi
echo "$today.$branch-$revision$dirty"

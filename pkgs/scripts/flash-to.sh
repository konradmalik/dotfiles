#!/usr/bin/env bash
set -euo pipefail

# credit to https://github.com/MatthewCroughan/nixcfg
if [ "$(file "$1" --mime-type -b)" = "application/zstd" ]; then
    echo "Flashing zst using zstdcat | dd"
    (
        set -x
        zstdcat "$1" | sudo dd of="$2" status=progress iflag=fullblock oflag=direct conv=fsync,noerror bs=64k
    )
elif [ "$(file "$2"--mime-type -b)" = "application/xz" ]; then
    echo "Flashing xz using xzcat | dd"
    (
        set -x
        xzcat "$1" | sudo dd of="$2" status=progress iflag=fullblock oflag=direct conv=fsync,noerror bs=64k
    )
else
    echo "Flashing arbitrary file $1 to $2"
    sudo dd if="$1" of="$2" status=progress conv=sync,noerror bs=64k
fi

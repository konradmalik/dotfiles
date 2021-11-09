#!/bin/bash

set -e

# TODO do this stuff in ansible (separate playbook?)
yay="yay -S --sudoloop --answerdiff=None --noconfirm --removemake --devel --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu"

echo "installing DE apps"
$yay xorg-xinit xorg-server xclip i3 rofi

echo "installing other apps"
$yay zathura-pdf-mupdf

# make i3 executable with 'startx'
echo "exec i3" > ~/.xinitrc

#!/bin/bash -e

# Make config directory for Neovim's init.vim
echo '[*] Preparing Neovim config directory ...'
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim

# Link init.lua, lua and plugin in current working directory to nvim's config location ...
echo '[*] Linking init.lua -> ~/.config/nvim/init.lua'
ln -s $PWD/init.lua ~/.config/nvim/
echo '[*] Linking lua -> ~/.config/nvim/lua'
ln -s $PWD/lua ~/.config/nvim/lua
echo '[*] Linking plugin -> ~/.config/nvim/plugin'
ln -s $PWD/plugin ~/.config/nvim/plugin

echo -e "[+] Done, welcome to mNeoVim! remember to run PackerInstall after first run, install language servers etc..." 


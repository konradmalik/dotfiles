local fn = vim.fn
local g = vim.g
local cmd = vim.cmd
local execute = vim.api.nvim_command

-- map leader to comma
g.mapleader = ','

-- sensible defaults
require('settings')

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
cmd [[
    packadd packer.nvim
    autocmd BufWritePost plugins.lua PackerCompile
]] -- Auto compile when there are changes in plugins.lua

-- Install plugins
require('plugins')

-- Key mappings
require('keymappings')

-- plugins configurations in lua
require('config')

local g = vim.g
local cmd = vim.cmd

local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- map leader
g.mapleader = ' '

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- to navigate buffers in normal mode
keymap('n', '<S-h>', ':bprevious<CR>', opts)
keymap('n', '<S-l>', ':bnext<CR>', opts)

-- quick grep word under the cursor
keymap('n', '<leader>*', ':grep <cword><CR>', opts)

-- quickfix niceness
keymap('n', '<C-k>', ':cp<CR>', opts)
keymap('n', '<C-j>', ':cn<CR>', opts)
keymap('n', '<C-q>', ':lua require("user.utils").ToggleQFList(1)<CR>', opts)
keymap('n', '<leader>q', ':lua require("user.utils").ToggleQFList(0)<CR>', opts)

-- ctrl c as esc in insert mode? why not
keymap('i', '<C-c>', '<esc>', opts)


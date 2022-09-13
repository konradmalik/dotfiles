local g = vim.g

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- map leader
g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- to navigate buffers in normal mode
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<S-l>", ":bnext<CR>", opts)

-- quick grep word under the cursor
keymap.set("n", "<leader>*", ":grep <cword><CR>", opts)

-- quickfix niceness
keymap.set("n", "<C-k>", ":cprevious<CR>", opts)
keymap.set("n", "<C-j>", ":cnext<CR>", opts)
keymap.set("n", "<leader>k", ":lprevious<CR>", opts)
keymap.set("n", "<leader>j", ":lnext<CR>", opts)
keymap.set("n", "<C-q>", function() require("konrad.utils").ToggleQFList(1) end, opts)
keymap.set("n", "<leader>q", function() require("konrad.utils").ToggleQFList(0) end, opts)

-- ctrl c as esc in insert mode? why not
keymap.set("i", "<C-c>", "<esc>", opts)

-- Clear highlights
keymap.set("n", "<leader>hh", ":nohlsearch<CR>", opts)

-- select last pasted
keymap.set("n", "<leader>p", "`[v`]", opts)

-- best remap ever. replace selected by pasting and keep pasted in the register
keymap.set("v", "<leader>p", "\"_dp", opts)

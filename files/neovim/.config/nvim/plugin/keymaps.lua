local g = vim.g

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[konrad] " .. desc })
end

-- map leader
keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
g.mapleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- to navigate buffers in normal mode
keymap.set("n", "<S-h>", ":bprevious<CR>", opts_with_desc("Prev buffer"))
keymap.set("n", "<S-l>", ":bnext<CR>", opts_with_desc("Next buffer"))

-- quick grep word under the cursor
keymap.set("n", "<leader>*", ":grep <cword><CR>", opts_with_desc("Grep word under cursor"))

local utils = require("konrad.utils");
-- quickfix niceness
keymap.set("n", "<C-k>", ":cprevious<CR>", opts_with_desc("Go to previous QF element"))
keymap.set("n", "<C-j>", ":cnext<CR>", opts_with_desc("Go to next LL element"))
keymap.set("n", "<leader>k", ":lprevious<CR>", opts_with_desc("Go to previous LL element"))
keymap.set("n", "<leader>j", ":lnext<CR>", opts_with_desc("Go to next LL element"))
keymap.set("n", "<C-q>", function() utils.ToggleQFList(1) end, opts_with_desc("Toggle Quickfix List"))
keymap.set("n", "<leader>q", function() utils.ToggleQFList(0) end, opts_with_desc("Toggle Local List"))

-- ctrl c as esc in insert mode? why not
keymap.set("i", "<C-c>", "<esc>", opts_with_desc("Ctrl-c as ESC in insert mode"))

-- select last pasted
keymap.set("n", "<leader>p", "`[v`]", opts_with_desc("Select last pasted"))

-- best remap ever. replace selected by pasting and keep pasted in the register
keymap.set("v", "<leader>p", "\"_dp", opts_with_desc("Replace selected by pasting and keep pasted in the register"))

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

-- <Tab> to navigate buffers in normal mode
keymap('n', '<S-Tab>', ':bp<CR>', opts)
keymap('n', '<Tab>', ':bn<CR>', opts)

-- quick grep word under the cursor
keymap('n', '<leader>*', ':grep <cword><CR>', opts)

-- quickfix niceness
keymap('n', '<C-k>', ':cp<CR>', opts)
keymap('n', '<C-j>', ':cn<CR>', opts)
keymap('n', '<C-q>', ':lua ToggleQFList(1)<CR>', opts)
keymap('n', '<leader>q', ':lua ToggleQFList(0)<CR>', opts)

-- ctrl c as esc in insert mode? why not
keymap('i', '<C-c>', '<esc>', opts)

-- the_primeagen's quickfix toggler
-- local list
g.the_primeagen_qf_l = 0
-- global quick fix
g.the_primeagen_qf_g = 0

function ToggleQFList(global)
    if global == 1 then
        if g.the_primeagen_qf_g == 1 then
            g.the_primeagen_qf_g = 0
            cmd('cclose')
        else
            g.the_primeagen_qf_g = 1
            cmd('copen')
        end
    else
        if g.the_primeagen_qf_l == 1 then
            g.the_primeagen_qf_l = 0
            cmd('lclose')
        else
            g.the_primeagen_qf_l = 1
            cmd('lopen')
        end
    end
end

local utils = require('utils')
local g = vim.g
local cmd = vim.cmd

-- <Tab> to navigate buffers in normal mode
utils.map('n', '<S-Tab>', ':bp<CR>')
utils.map('n', '<Tab>', ':bn<CR>')

-- quick grep word under the cursor
utils.map('n', '<leader>*', ':grep <cword><CR>')

-- quickfix niceness
utils.map('n', '<C-k>', ':cp<CR>')
utils.map('n', '<C-j>', ':cn<CR>')
utils.map('n', '<C-q>', ':lua ToggleQFList(1)<CR>')
utils.map('n', '<leader>q', ':lua ToggleQFList(0)<CR>')

-- ctrl c as esc in insert mode? why not
utils.map('i', '<C-c>', '<esc>')

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

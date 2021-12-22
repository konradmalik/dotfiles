local utils = { }
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g

-- Deletes all trailing whitespaces in a file if it's not binary nor a diff.
function utils.trim_trailing_whitespace()
    if not o.binary and o.filetype ~= 'diff' then
        local current_view = fn.winsaveview()
        cmd([[keeppatterns %s/\s\+$//e]])
        fn.winrestview(current_view)
    end
end

-- the_primeagen's quickfix toggler
-- local list
g.the_primeagen_qf_l = 0
-- global quick fix
g.the_primeagen_qf_g = 0

function utils.ToggleQFList(global)
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

return utils

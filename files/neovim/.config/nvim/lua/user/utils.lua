local utils = { }
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd

-- Deletes all trailing whitespaces in a file if it's not binary nor a diff.
function utils.trim_trailing_whitespace()
    if not o.binary and o.filetype ~= 'diff' then
        local current_view = fn.winsaveview()
        cmd([[keeppatterns %s/\s\+$//e]])
        fn.winrestview(current_view)
    end
end

return utils

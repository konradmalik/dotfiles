local utils = { }
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd

-- set the key mapping
function utils.map(mode, lhs, rhs, opts)
    -- default options
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end

    -- basic support for buffer-scoped keybindings
    local buffer = options.buffer
    options.buffer = nil

    if buffer then
        vim.api.nvim_buf_set_keymap(0, mode, lhs, rhs, options)
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
    end
end

-- Deletes all trailing whitespaces in a file if it's not binary nor a diff.
function utils.trim_trailing_whitespace()
    if not o.binary and o.filetype ~= 'diff' then
        local current_view = fn.winsaveview()
        cmd([[keeppatterns %s/\s\+$//e]])
        fn.winrestview(current_view)
    end
end

return utils

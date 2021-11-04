local utils = { }

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

return utils

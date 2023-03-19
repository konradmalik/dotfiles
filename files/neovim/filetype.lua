-- The do_filetype_lua global variable activates the Lua filetype detection mechanism, which runs before the legacy Vim script filetype detection.
-- Note that this does not disable the existing filetype detection checks!
-- This means that you will be using both Lua and Vim script filetype detection, which will actualy increase your startuptime.
-- This is necessary for now simply because filetype.lua does not yet have parity with filetype.vim,
-- so there are some filetypes that filetype.lua will not successfully detect.

vim.filetype.add({
    -- filename = {
    --     ["README$"] = function(path, bufnr)
    --         if string.find("#", vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)) then
    --             return "markdown"
    --         end
    --
    --         -- no return means the filetype won't be set and to try the next method
    --     end,
    --     extension = {
    --         foo = "fooscript",
    --     },
    -- }
    filename = {
        -- Earthfile = "dockerfile",
        Tiltfile = "python",
    },
})

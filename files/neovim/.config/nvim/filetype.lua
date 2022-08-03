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
        ["Earthfile"] = "Dockerfile",
        ["Tiltfile"] = "python",
    },
})

return function(group)
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        desc = "Lazily initialize luasnip",
        once = true,
        callback = function()
            vim.cmd('packadd luasnip')
            vim.cmd('packadd friendly-snippets')
            require("luasnip").config.setup {}
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    })
end

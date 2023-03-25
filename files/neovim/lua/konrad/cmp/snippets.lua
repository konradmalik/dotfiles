return function(group)
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        desc = "Lazily initialize luasnip",
        once = true,
        callback = function()
            vim.cmd('packadd luasnip')
            require("luasnip")
            vim.cmd('packadd friendly-snippets')
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    })
end

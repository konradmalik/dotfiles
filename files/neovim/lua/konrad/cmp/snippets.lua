local initialize = function()
    vim.cmd('packadd luasnip')
    vim.cmd('packadd friendly-snippets')
    require("konrad.luasnip")
    require("luasnip.loaders.from_vscode").lazy_load()
end

return function(group)
    vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        desc = "Lazily initialize snippets completion",
        once = true,
        callback = initialize,
    })
end

local mason_null_ls_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_ok then
    vim.notify("cannot load mason-null-ls")
    return
end

local tools = {
    "prettier",
    "shfmt",
    "black",
    "isort",

    "mypy",
    "shellcheck",
}

mason_null_ls.setup({
    ensure_installed = tools,
    automatic_installation = true,
})
mason_null_ls.check_install(true)

vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonNullLsUpdateCompleted',
    callback = function()
        vim.schedule(function() print('mason-null-ls has finished') end)
    end,
})

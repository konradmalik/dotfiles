local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if not mason_tool_installer_ok then
    vim.notify("cannot load mason-tool-installer")
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

mason_tool_installer.setup({
    ensure_installed = tools,
})

vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    callback = function()
        vim.schedule(function()
            print 'mason-tool-installer lsp has finished'
        end)
    end,
})
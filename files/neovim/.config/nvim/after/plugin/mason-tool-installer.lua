local mason_tool_installer_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
if not mason_tool_installer_ok then
    vim.notify("cannot load mason-tool-installer")
    return
end

local tools = {
    -- fmt
    "prettier",
    "shfmt",
    "black",
    "isort",
    -- lint
    "mypy",
    "shellcheck",
    -- dap
    "delve",
    "debugpy",
    "netcoredbg",
}

mason_tool_installer.setup({
    ensure_installed = tools,
    auto_update = false,
})

vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    callback = function()
        vim.schedule(function()
            vim.notify('mason-tool-installer has finished')
        end)
    end,
})

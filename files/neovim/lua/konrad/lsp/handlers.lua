local M = {}
local keymaps = require("konrad.lsp.keymaps")
local navic = require("konrad.lsp.navic")

M.on_attach = function(client, bufnr)
    -- lsp keymaps
    keymaps(client, bufnr)
    -- navigation bar
    navic(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- cmp provides more capabilites
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
    local cmp_capabilities = cmp_nvim_lsp.default_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_capabilities)
else
    vim.notify("cannot load cmp_nvim_lsp")
end

M.capabilities = capabilities

return M

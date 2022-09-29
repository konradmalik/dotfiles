local M = {}
local utils = require("konrad.utils")
local keymaps = require("konrad.lsp.keymaps")
local highlight = require("konrad.lsp.highlight")
local navic_disallowed_servers = {}

local navic_ok, navic = pcall(require, "nvim-navic")
if not navic_ok then
    vim.notify("cannot load navic")
end


M.on_attach = function(client, bufnr)
    -- lsp keymaps
    keymaps(client, bufnr)
    -- lsp highlight if available
    highlight(client, bufnr)
    -- navigation bar (keep last due to return logic below)
    if not navic_ok then
        return
    end
    if not client.server_capabilities.documentSymbolProvider then
        -- vim.notify(client.name .. ' does not serve as a documentSymbolProvider')
        return
    end
    if utils.has_value(navic_disallowed_servers, client.name) then
        -- vim.notify(client.name .. ' was disabled manually in navic')
        return
    end
    navic.attach(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- capabilites for cmp
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
    capabilities.textDocument.semanticHighlighting = true
    capabilities.offsetEncoding = "utf-8"
else
    vim.notify("cannot load cmp_nvim_lsp")
end

M.capabilities = capabilities

return M

local M = {}
local utils = require("user.utils")
local keymaps = require("user.lsp.keymaps")
local highlight = require("user.lsp.highlight")
local navic_disallowed_servers = {}

local navic_ok, navic = pcall(require, "nvim-navic")
if not navic_ok then
    vim.notify("cannot load navic")
end

local icons = require("user.icons")
local diagnostic_icons = icons.diagnostics

M.setup = function()
    local signs = {
        { name = "DiagnosticSignError", text = diagnostic_icons.Error },
        { name = "DiagnosticSignWarn", text = diagnostic_icons.Warning },
        { name = "DiagnosticSignHint", text = diagnostic_icons.Hint },
        { name = "DiagnosticSignInfo", text = diagnostic_icons.Information },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
    end

    local config = {
        virtual_text = { prefix = icons.ui.Square },
        signs = {
            active = signs,
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
            style = "minimal",
            source = "always",
            prefix = "", -- removes numbers
            header = "", -- removes "diagnostics" title
        },
    }

    vim.diagnostic.config(config)
end

M.on_attach = function(client, bufnr)
    -- lsp keymaps
    keymaps(client, bufnr)
    -- lsp highlighting
    highlight(client, bufnr)
    -- navigation bar (keep last due to return logic below)
    if not navic_ok then
        return
    end
    if not client.server_capabilities.documentSymbolProvider then
        vim.notify(client.name .. ' does not serve as a documentSymbolProvider')
        return
    end
    if utils.has_value(navic_disallowed_servers, client.name) then
        vim.notify(client.name .. ' was disabled manually in navic')
        return
    end
    navic.attach(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- capabilites for cmp
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
    local cmp_capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
    cmp_capabilities.textDocument.semanticHighlighting = true
    cmp_capabilities.offsetEncoding = "utf-8"

    M.capabilities = cmp_capabilities
else
    vim.notify("cannot load cmp_nvim_lsp")
end

return M

local M = {}
local utils = require("user.utils")
local keymaps = require("user.lsp.keymaps")
local navic_disallowed_servers = {}

local navic_ok, navic = pcall(require, "nvim-navic")
if not navic_ok then
    vim.notify("cannot load navic")
end

local illuminate_ok, illuminate = pcall(require, "illuminate")
if not illuminate_ok then
    vim.notify("cannot load illuminate")
end

M.setup = function()
    local config = {
        -- disable virtual text
        virtual_text = false,
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
        },
    }

    vim.diagnostic.config(config)
end

M.on_attach = function(client, bufnr)
    -- keymaps
    keymaps(client, bufnr)
    -- same word highlighting
    if illuminate_ok then
        illuminate.on_attach(client, bufnr)
    end
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
-- add it to each server you want
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_nvim_lsp_ok then
    M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
else
    vim.notify("cannot load cmp_nvim_lsp")
end

return M

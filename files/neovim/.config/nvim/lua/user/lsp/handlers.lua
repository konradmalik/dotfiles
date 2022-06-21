local M = {}
local keymap = vim.keymap
local utils = require("user.utils")

local navic_ok, navic = pcall(require, "nvim-navic")
if not navic_ok then
    vim.notify("cannot load navic")
    return
end
local navic_disallowed_servers = { "pylsp" }

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

local lsp_keymaps = function(client, bufnr)
    -- Mappings.
    local opts = { buffer = bufnr, noremap = true }
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    keymap.set("n", "gh", vim.lsp.buf.hover, opts)
    keymap.set("n", "gp", vim.lsp.buf.implementation, opts)
    keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
    keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    keymap.set("n", "gr", vim.lsp.buf.references, opts)
    keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

    -- we have autocmd
    --keymap.set('n', '<leader>q', vim.lsp.diagnostic.set_loclist, opts)

    keymap.set("n", "<leader>f", vim.lsp.buf.formatting, opts)
    keymap.set("v", "<leader>f", vim.lsp.buf.range_formatting, opts)
end

M.on_attach = function(client, bufnr)
    -- keymaps
    lsp_keymaps(client, bufnr)
    -- navigation bar
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

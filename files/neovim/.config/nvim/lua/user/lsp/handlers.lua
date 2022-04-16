local M = {}
local keymap = vim.keymap

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
    local function buf_set_keymap(...)
        keymap.set(bufnr, ...)
    end

    -- Mappings.
    local opts = { noremap = true }
    buf_set_keymap("n", "gD", vim.lsp.buf.declaration, opts)
    buf_set_keymap("n", "gd", vim.lsp.buf.definition, opts)
    buf_set_keymap("n", "gh", vim.lsp.buf.hover, opts)
    buf_set_keymap("n", "gp", vim.lsp.buf.implementation, opts)
    buf_set_keymap("n", "gs", vim.lsp.buf.signature_help, opts)
    buf_set_keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    buf_set_keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    buf_set_keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    buf_set_keymap("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    buf_set_keymap("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    buf_set_keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
    buf_set_keymap("n", "gr", vim.lsp.buf.references, opts)
    buf_set_keymap("n", "<leader>e", vim.diagnostic.open_float, opts)
    buf_set_keymap("n", "[d", vim.diagnostic.goto_prev, opts)
    buf_set_keymap("n", "]d", vim.diagnostic.goto_next, opts)

    -- we have autocmd
    --buf_set_keymap('n', '<leader>q', vim.lsp.diagnostic.set_loclist, opts)

    buf_set_keymap("n", "<leader>f", vim.lsp.buf.formatting, opts)
    buf_set_keymap("v", "<leader>f", vim.lsp.buf.range_formatting, opts)
end

M.on_attach = function(client, bufnr)
    lsp_keymaps(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- capabilites for cmp
-- add it to each server you want
local cmp_nvim_lsp = require("cmp_nvim_lsp")
M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M

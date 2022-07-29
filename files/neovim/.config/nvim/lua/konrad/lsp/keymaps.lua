local keymap = vim.keymap

local lsp_keymaps = function(client, bufnr)
    local opts = { buffer = bufnr, noremap = true }

    -- Mappings.
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    keymap.set("n", "K", vim.lsp.buf.hover, opts)
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

return lsp_keymaps

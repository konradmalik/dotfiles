local keymap = vim.keymap

local lsp_keymaps = function(client, bufnr)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
    keymap.set("n", "gp", vim.lsp.buf.implementation, opts)
    keymap.set("n", "gr", vim.lsp.buf.references, opts)
    keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
    keymap.set("n", "K", vim.lsp.buf.hover, opts)
    keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end, opts)
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)
end

return lsp_keymaps

local keymap = vim.keymap

local lsp_keymaps = function(client, bufnr)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    local opts_with_desc = function(desc)
        return vim.tbl_extend("error", opts, { desc = "[LSP] " .. desc })
    end
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    keymap.set("n", "gd", vim.lsp.buf.definition, opts_with_desc("Go To Definition"))
    keymap.set("n", "gT", vim.lsp.buf.type_definition, opts_with_desc("Go To Type Definition"))
    keymap.set("n", "gp", vim.lsp.buf.implementation, opts_with_desc("Go To Implementation"))
    keymap.set("n", "gr", vim.lsp.buf.references, opts_with_desc("References"))
    keymap.set("n", "gs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover"))
    keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts_with_desc("Add Workspace Folder"))
    keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts_with_desc("Remove Workspace Folder"))
    keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end,
        opts_with_desc("List Workspace Folders"))
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_with_desc("Rename"))

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

return lsp_keymaps

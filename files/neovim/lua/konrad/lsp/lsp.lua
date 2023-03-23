local telescope_ok, telescope = pcall(require, 'telescope.builtin')

local _augroups = {}

-- @param purpose string
local get_augroup = function(client)
    if not _augroups[client.id] then
        local group_name = 'personal-lsp-' .. client.name
        local id = vim.api.nvim_create_augroup(group_name, { clear = true })
        _augroups[client.id] = id
    end

    return _augroups[client.id]
end

local format_is_enabled = true;
vim.api.nvim_create_user_command('AutoFormatToggle', function()
    format_is_enabled = not format_is_enabled
    print('Setting autoformatting to: ' .. tostring(format_is_enabled))
end, {})

local codelens_is_enabled = true;
vim.api.nvim_create_user_command('CodelensToggle', function()
    codelens_is_enabled = not codelens_is_enabled
    print('Setting codelens to: ' .. tostring(codelens_is_enabled))
end, {})

local highlight_is_enabled = true;
vim.api.nvim_create_user_command('DocumentHighlightToggle', function()
    highlight_is_enabled = not highlight_is_enabled
    if not highlight_is_enabled then
        vim.lsp.buf.clear_references()
    end
    print('Setting document highlight to: ' .. tostring(highlight_is_enabled))
end, {})

return function(client, bufnr)
    local capabilities = client.server_capabilities
    local augroup = get_augroup(client)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    local opts_with_desc = function(desc)
        return vim.tbl_extend("error", opts, { desc = "[LSP] " .. desc })
    end

    if capabilities.codeActionProvider then
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    end

    if capabilities.codeLensProvider then
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if format_is_enabled then
                    vim.lsp.codelens.refresh()
                end
            end,
            desc = "Refresh codelens",
        })
        vim.lsp.codelens.refresh()
        vim.api.nvim_buf_create_user_command(bufnr, 'CodeLensRefresh', vim.lsp.codelens.refresh,
            { desc = 'Refresh codelens for the current buffer' })
        vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))
    end

    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd('BufWritePre', {
            desc = "AutoFormat on save",
            group = augroup,
            buffer = bufnr,
            callback = function()
                if format_is_enabled then
                    vim.lsp.buf.format {
                        async = false,
                        filter = function(c)
                            return c.id == client.id
                        end,
                    }
                end
            end,
        })
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', vim.lsp.buf.format,
            { desc = 'Format current buffer with LSP' })
    end

    if capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if highlight_is_enabled then
                    vim.lsp.buf.document_highlight()
                end
            end,
            desc = "Highlight references when cursor holds",
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            group = augroup,
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
            desc = "Clear references when cursor moves",
        })
    end

    if capabilities.declarationProvider then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_with_desc("Go To Declaration"))
    end

    if capabilities.definitionProvider then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts_with_desc("Go To Definition"))
        if telescope_ok then
            vim.keymap.set("n", "<leader>fd", telescope.lsp_definitions, opts_with_desc("Telescope [D]efinitions"))
        end
    end

    if capabilities.hoverProvider then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_with_desc("Hover"))
    end

    if capabilities.implementationProvider then
        vim.keymap.set("n", "gp", vim.lsp.buf.implementation, opts_with_desc("Go To Implementation"))
        if telescope_ok then
            vim.keymap.set("n", "<leader>fp", telescope.lsp_implementations,
                opts_with_desc("Telescope Im[p]lementations"))
        end
    end

    if capabilities.referencesProvider then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts_with_desc("References"))
        if telescope_ok then
            vim.keymap.set("n", "<leader>fr", telescope.lsp_references, opts_with_desc("Telescope [R]eferences"))
        end
    end

    if capabilities.renameProvider then
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_with_desc("Rename"))
    end

    if capabilities.signatureHelpProvider then
        vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts_with_desc("Signature Help"))
    end

    if capabilities.typeDefinitionProvider then
        vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts_with_desc("Go To Type Definition"))
        if telescope_ok then
            vim.keymap.set("n", "<leader>fT", telescope.lsp_type_definitions,
                opts_with_desc("Telescope [T]ype Definitions"))
        end
    end

    if capabilities.workspaceSymbolProvider then
        vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts_with_desc("Search workspace symbols"))
        if telescope_ok then
            vim.keymap.set("n", "<leader>fws", telescope.lsp_workspace_symbols,
                opts_with_desc("Telescope [W]orkspace [S]ymbols"))
        end
    end

    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts_with_desc("Add Workspace Folder"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts_with_desc("Remove Workspace Folder"))
    vim.keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end,
        opts_with_desc("List Workspace Folders"))

end

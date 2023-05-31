local utils = require("konrad.utils")
local telescope_ok, telescope = pcall(require, 'telescope.builtin')

local keymap_prefix = "[LSP]"

local M = {}

-- client id to group id mapping
local _augroups = {}

---@param client table
---@return integer
local get_augroup = function(client)
    if not _augroups[client.id] then
        local group_name = 'personal-lsp-' .. client.name
        local group = vim.api.nvim_create_augroup(group_name, { clear = true })
        _augroups[client.id] = group
        return group
    end
    return _augroups[client.id]
end

-- client-id to command name
local commands = {};
-- client id to buf command name (don't need to store buf here since del requires a buf arg so we won't delete stuff by
-- accident)
local buf_commands = {};

---@param ttable table
---@param key any
---@param value any
local insert_into_nested = function(ttable, key, value)
    if not ttable[key] then
        ttable[key] = {}
    end
    table.insert(ttable[key], value)
end

M.get_augroup = get_augroup
M.detach = function(client, bufnr)
    local augroup = get_augroup(client)
    local aucmds = vim.api.nvim_get_autocmds({
        group = augroup,
        buffer = bufnr,
    })
    for _, aucmd in ipairs(aucmds) do
        pcall(vim.api.nvim_del_autocmd, aucmd.id)
    end

    local client_commands = commands[client.id]
    if client_commands then
        for _, cmd in ipairs(client_commands) do
            pcall(vim.api.nvim_del_user_command, cmd)
        end
    end

    local client_buf_commands = buf_commands[client.id]
    if client_buf_commands then
        for _, buf_cmd in ipairs(client_buf_commands) do
            pcall(vim.api.nvim_buf_del_user_command, bufnr, buf_cmd)
        end
    end

    for _, mode in ipairs({ 'n', 'i', 'v' }) do
        local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
        for _, keymap in ipairs(keymaps) do
            if keymap.desc then
                if utils.stringstarts(keymap.desc, keymap_prefix) then
                    pcall(vim.api.nvim_buf_del_keymap, bufnr, mode, keymap.lhs)
                end
            end
        end
    end

    pcall(vim.lsp.codelens.clear)
    local inlayhints_ok, inlayhints = pcall(require, 'lsp-inlayhints')
    if inlayhints_ok then inlayhints.reset() end
end

M.attach = function(client, bufnr)
    local capabilities = client.server_capabilities
    local augroup = get_augroup(client)

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    local opts_with_desc = function(desc)
        return vim.tbl_extend("error", opts, { desc = keymap_prefix .. " " .. desc })
    end

    if capabilities.codeActionProvider then
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts_with_desc("Code Action"))
    end

    if capabilities.codeLensProvider then
        local codelens_is_enabled = true;
        local command = "CodeLensToggle"
        insert_into_nested(commands, client.id, command)
        vim.api.nvim_create_user_command(command,
            function()
                codelens_is_enabled = not codelens_is_enabled
                if not codelens_is_enabled then
                    vim.lsp.codelens.clear()
                end
                print('Setting codelens to: ' .. tostring(codelens_is_enabled))
            end, {
                desc = "Enable/disable codelens with lsp",
            })

        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
            group = augroup,
            buffer = bufnr,
            callback = function()
                if codelens_is_enabled then
                    vim.lsp.codelens.refresh()
                end
            end,
            desc = "Refresh codelens",
        })
        -- refresh now as well
        vim.lsp.codelens.refresh()

        command = "CodeLensRefresh"
        insert_into_nested(buf_commands, client.id, command)
        vim.api.nvim_buf_create_user_command(bufnr, command, vim.lsp.codelens.refresh,
            { desc = 'Refresh codelens for the current buffer' })
        vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts_with_desc("CodeLens run"))
    end

    -- why this check here?
    -- because null-ls is specific, in that it registers documentFormattingProvider
    -- only for specific filetypes (correctly set in client.config.filetypes)
    -- but it attaches itself to all files (eg. if git_signs code action is enabled).
    -- The result is that an autocommand that always fails in created for null_ls.
    -- We're avoiding this situation here.
    local properDocumentFormattingProvider = (client.name ~= "null-ls" or utils.is_matching_filetype(client.config)) and
        capabilities.documentFormattingProvider

    if properDocumentFormattingProvider then
        local format_is_enabled = true;
        local command = "AutoFormatToggle"
        insert_into_nested(commands, client.id, command)
        vim.api.nvim_create_user_command(command,
            function()
                format_is_enabled = not format_is_enabled
                print('Setting autoformatting to: ' .. tostring(format_is_enabled))
            end, {
                desc = "Enable/disable autoformat with lsp",
            })

        vim.api.nvim_create_autocmd('BufWritePre', {
            desc = "AutoFormat on save",
            group = augroup,
            buffer = bufnr,
            -- why pcall? null-ls registers itself as formatter, but
            -- it attaches to all buffers
            callback = function()
                if format_is_enabled then
                    vim.lsp.buf.format({
                        async = false,
                        id = client.id,
                        bufnr = bufnr,
                    })
                end
            end,
        })
        command = "Format"
        insert_into_nested(buf_commands, client.id, command)
        vim.api.nvim_buf_create_user_command(bufnr, command,
            function()
                vim.lsp.buf.format({
                    async = false,
                    id = client.id,
                    bufnr = bufnr,
                })
            end,
            { desc = 'Format current buffer with LSP' })
    end

    if capabilities.documentHighlightProvider then
        local highlight_is_enabled = true;
        local command = "DocumentHighlightToggle"
        insert_into_nested(commands, client.id, command)
        vim.api.nvim_create_user_command(command,
            function()
                highlight_is_enabled = not highlight_is_enabled
                if not highlight_is_enabled then
                    vim.lsp.buf.clear_references()
                end
                print('Setting document highlight to: ' .. tostring(highlight_is_enabled))
            end, {
                desc = "Enable/disable highlight word under cursor with lsp",
            })

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

    if capabilities.inlayHintProvider then
        vim.cmd('packadd lsp-inlayhints.nvim')
        local inlayhints_ok, inlayhints = pcall(require, 'lsp-inlayhints')
        if inlayhints_ok then
            local inlayhints_is_enabled = true;
            local command = "InlayHintsToggle"
            insert_into_nested(commands, client.id, command)
            vim.api.nvim_create_user_command(command,
                function()
                    inlayhints_is_enabled = not inlayhints_is_enabled
                    inlayhints.toggle()
                    if inlayhints_is_enabled then
                        inlayhints.show()
                    else
                        inlayhints.reset()
                    end
                    print('Setting inlayhints to: ' .. tostring(inlayhints_is_enabled))
                end, {
                    desc = "Enable/disable inlayhints with lsp",
                })

            inlayhints.setup({ enabled_at_startup = inlayhints_is_enabled })
            inlayhints.on_attach(client, bufnr)
        end
    end

    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts_with_desc("Add Workspace Folder"))
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts_with_desc("Remove Workspace Folder"))
    vim.keymap.set("n", "<leader>wl", function() P(vim.lsp.buf.list_workspace_folders()) end,
        opts_with_desc("List Workspace Folders"))
end

return M

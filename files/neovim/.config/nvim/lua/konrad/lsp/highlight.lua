-- instead of that we use vim-illuminate as it automatically fallsback on treesitter or even regex
local function lsp_highlight(client, bufnr)
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.documentHighlightProvider then
        local group = vim.api.nvim_create_augroup("lsp_document_highlight", {
            clear = false
        })
        vim.api.nvim_clear_autocmds({
            group = group,
            buffer = bufnr,
        })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            callback = vim.lsp.buf.document_highlight,
            buffer = bufnr,
            group = group,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = vim.lsp.buf.clear_references,
            group = group,
            buffer = bufnr,
        })
    end
end

return lsp_highlight

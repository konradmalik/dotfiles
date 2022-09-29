local M = {}

local HL_NAMESPACE = vim.api.nvim_create_namespace('illuminate.highlight')

local function kind_to_hl_group(kind)
    return kind == vim.lsp.protocol.DocumentHighlightKind.Text and 'LspReferenceText'
        or kind == vim.lsp.protocol.DocumentHighlightKind.Read and 'LspReferenceRead'
        or kind == vim.lsp.protocol.DocumentHighlightKind.Write and 'LspReferenceWrite'
        or 'LspReferenceText'
        -- or 'illuminatedWord'
end

function M.buf_highlight_references(bufnr, references)
    for _, reference in ipairs(references) do
        M.range(
            bufnr,
            reference[1],
            reference[2],
            reference[3]
        )
    end
end

function M.range(bufnr, start, finish, kind)
    local region = vim.region(bufnr, start, finish, 'v', false)
    for linenr, cols in pairs(region) do
        -- if you can't see the highlight, it's because of hl_group
        -- type :hi to see available groups, choose one that will be visible and use it
        vim.api.nvim_buf_add_highlight(bufnr, HL_NAMESPACE, kind_to_hl_group(kind), linenr, cols[1], cols[2])
    end
end

function M.buf_clear_references(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, HL_NAMESPACE, 0, -1)
end

return M

local highlight = require("konrad.treesitter.highlight")
local provider = require("konrad.treesitter.provider")

local function do_highlight()
    local bufnr = 0
    local refs = provider.get_references(bufnr)
    if refs then
        highlight.buf_highlight_references(bufnr, refs)
    end
end

local function clear_highlight()
    local bufnr = 0
    highlight.buf_clear_references(bufnr)
end

local function treesitter_highlight()
    -- keep the group name the same as lsp to avoid double highlight
    -- also clear is true because of that
    local group = vim.api.nvim_create_augroup("konrad_document_highlight", {
        clear = true
    })
    vim.api.nvim_clear_autocmds({
        group = group,
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        callback = do_highlight,
        group = group,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
        callback = clear_highlight,
        group = group,
    })
end

local M = {}
M.setup = treesitter_highlight

return M

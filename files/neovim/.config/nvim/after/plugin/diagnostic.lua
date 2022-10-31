local icons = require("konrad.icons")
local diagnostic_icons = icons.diagnostics

local signs = {
    { name = "DiagnosticSignError", text = diagnostic_icons.Error },
    { name = "DiagnosticSignWarn", text = diagnostic_icons.Warning },
    { name = "DiagnosticSignHint", text = diagnostic_icons.Hint },
    { name = "DiagnosticSignInfo", text = diagnostic_icons.Information },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
end

vim.diagnostic.config({
    virtual_text = { prefix = icons.ui.Square },
    signs = {
        active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = "minimal",
        source = "always",
        prefix = "", -- removes numbers
        header = "", -- removes "diagnostics" title
    },
})

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = desc })
end

keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts_with_desc("Open diagnostic in floating window"))
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts_with_desc("Previous diagnostic"))
keymap.set("n", "]d", vim.diagnostic.goto_next, opts_with_desc("Next diagnostic"))
keymap.set('n', '<leader>ll', vim.diagnostic.setloclist,
    opts_with_desc("Send diagnostics from current buffer to location list"))
keymap.set('n', '<leader>lq', vim.diagnostic.setqflist, opts_with_desc("Send all diagnostics to QF list"))

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
local opts = { noremap = true }

keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
-- we have autocmd
--keymap.set('n', '<leader>q', vim.lsp.diagnostic.set_loclist, opts)

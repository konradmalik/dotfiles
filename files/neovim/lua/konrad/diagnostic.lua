local icons = require("konrad.icons")

vim.diagnostic.config({
    underline = true,
    virtual_text = {
        prefix = icons.ui.Square,
        source = false,
        spacing = 4,
    },
    update_in_insert = false,
    severity_sort = true,
    float = {
        source = "always",
        prefix = "", -- removes numbers
        header = "", -- removes "diagnostics" title
    },
})

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Diagnostic] " .. desc })
end

keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts_with_desc("Open in floating window"))
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts_with_desc("Previous"))
keymap.set("n", "]d", vim.diagnostic.goto_next, opts_with_desc("Next"))
keymap.set('n', '<leader>ll', vim.diagnostic.setloclist,
    opts_with_desc("Send all from current buffer to location list"))
keymap.set('n', '<leader>lq', vim.diagnostic.setqflist, opts_with_desc("Send all to QF list"))

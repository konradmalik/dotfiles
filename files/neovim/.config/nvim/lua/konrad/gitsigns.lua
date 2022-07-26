local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    vim.notify("gitsigns cannot be initialized!")
    return
end
local diff = require("konrad.diff")

gitsigns.setup({
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>gj", gitsigns.next_hunk, opts)
keymap.set("n", "<leader>gk", gitsigns.prev_hunk, opts)
keymap.set("n", "<leader>gp", gitsigns.preview_hunk, opts)
keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts)
keymap.set("n", "<leader>gR", gitsigns.reset_buffer, opts)
keymap.set("n", "<leader>gs", gitsigns.stage_hunk, opts)
keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, opts)
-- custom
keymap.set("n", "<leader>gd", diff, opts)

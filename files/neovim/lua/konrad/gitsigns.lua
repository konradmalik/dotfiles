local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    vim.notify("gitsigns cannot be initialized!")
    return
end

gitsigns.setup({
    signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '-' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
})

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Gitsigns] " .. desc })
end

keymap.set("n", "<leader>gj", gitsigns.next_hunk, opts_with_desc("Next Hunk"))
keymap.set("n", "<leader>gk", gitsigns.prev_hunk, opts_with_desc("Prev Hunk"))
keymap.set("n", "<leader>gp", gitsigns.preview_hunk, opts_with_desc("Preview Hunk"))
keymap.set("n", "<leader>gr", gitsigns.reset_hunk, opts_with_desc("Reset Hunk"))
keymap.set("n", "<leader>gR", gitsigns.reset_buffer, opts_with_desc("Reset Buffer"))
keymap.set("n", "<leader>gs", gitsigns.stage_hunk, opts_with_desc("Stage Hunk"))
keymap.set("n", "<leader>gu", gitsigns.undo_stage_hunk, opts_with_desc("Undo Stage Hunk"))

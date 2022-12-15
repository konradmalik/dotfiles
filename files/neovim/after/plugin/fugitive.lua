local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Fugitive] " .. desc })
end

keymap.set("n", "<leader>gS", "<cmd>Git<CR>", opts_with_desc("Git status"))
keymap.set("n", "<leader>gh", "<cmd>0Gclog<CR>", opts_with_desc("Git file log"))
keymap.set("n", "<leader>gl", "<cmd>G blame<CR>", opts_with_desc("Git blame"))
keymap.set("n", "<leader>gL", "<cmd>Gclog<CR>", opts_with_desc("Git log"))
keymap.set("n", "<leader>gP", "<cmd>G push<CR>", opts_with_desc("Git push"))

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>gS", "<cmd>Git<CR>", opts)
keymap.set("n", "<leader>gh", "<cmd>0Gclog<CR>", opts)
keymap.set("n", "<leader>gl", "<cmd>G blame<CR>", opts)
keymap.set("n", "<leader>gL", "<cmd>Gclog<CR>", opts)
keymap.set("n", "<leader>gP", "<cmd>G push<CR>", opts)

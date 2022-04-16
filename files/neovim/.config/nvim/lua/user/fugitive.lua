local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Git status
keymap.set("n", "<Leader>gs", "<cmd>Git<CR>", opts)

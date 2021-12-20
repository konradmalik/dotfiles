local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Git status
keymap('n', '<Leader>gs', '<cmd>Git<CR>', opts)

require('telescope')
local utils = require('utils')
local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
-- Mappings.
local opts = { noremap=true }
utils.map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
utils.map('n', '<leader>ft', "<cmd>lua require('telescope.builtin').file_browser()<cr>", opts)
utils.map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
utils.map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)
utils.map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", opts)

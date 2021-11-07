-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

local utils = require('utils')
-- Mappings.
local opts = { noremap=true }
utils.map('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
utils.map('n', '<leader>ft', "<cmd>lua require('telescope.builtin').file_browser()<cr>", opts)
utils.map('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
utils.map('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", opts)
utils.map('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", opts)

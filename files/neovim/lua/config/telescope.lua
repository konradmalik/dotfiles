require('telescope')
local utils = require('utils')
local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
-- Mappings.
local opts = { noremap=true }
utils.map('n', '<leader>tf', '<Cmd>Telescope find_files<CR>', opts)
utils.map('n', '<leader>tt', '<Cmd>Telescope file_browser<CR>', opts)
utils.map('n', '<leader>tg', '<Cmd>Telescope live_grep<CR>', opts)
utils.map('n', '<leader>tb', '<Cmd>Telescope buffers<CR>', opts)
utils.map('n', '<leader>th', '<Cmd>Telescope help_tags<CR>', opts)

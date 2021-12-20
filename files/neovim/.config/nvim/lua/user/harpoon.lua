local harpoon = require('harpoon')

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

harpoon.setup()

keymap('n', '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>', opts)
keymap('n', '<leader>hi', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', opts)
keymap('n', '<leader>hj', ':lua require("harpoon.ui").nav_file(1)<CR>', opts)
keymap('n', '<leader>hk', ':lua require("harpoon.ui").nav_file(2)<CR>', opts)
keymap('n', '<leader>hl', ':lua require("harpoon.ui").nav_file(3)<CR>', opts)
keymap('n', '<leader>h;', ':lua require("harpoon.ui").nav_file(4)<CR>', opts)


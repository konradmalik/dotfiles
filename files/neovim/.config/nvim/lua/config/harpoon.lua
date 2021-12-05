local utils = require('utils')
local harpoon = require('harpoon')

harpoon.setup()

utils.map('n', '<leader>ha', ':lua require("harpoon.mark").add_file()<CR>')
utils.map('n', '<leader>hi', ':lua require("harpoon.ui").toggle_quick_menu()<CR>')
utils.map('n', '<leader>hj', ':lua require("harpoon.ui").nav_file(1)<CR>')
utils.map('n', '<leader>hk', ':lua require("harpoon.ui").nav_file(2)<CR>')
utils.map('n', '<leader>hl', ':lua require("harpoon.ui").nav_file(3)<CR>')
utils.map('n', '<leader>h;', ':lua require("harpoon.ui").nav_file(4)<CR>')


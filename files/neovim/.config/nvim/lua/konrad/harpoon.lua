local harpoon_ok, harpoon = pcall(require, "harpoon")
if not harpoon_ok then
    vim.notify("cannot load harpoon")
    return
end

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

harpoon.setup()

keymap.set("n", "<leader>ha", require("harpoon.mark").add_file, opts)
keymap.set("n", "<leader>ht", require("harpoon.ui").toggle_quick_menu, opts)
keymap.set("n", "<leader>hj", function() require("harpoon.ui").nav_file(1) end, opts)
keymap.set("n", "<leader>hk", function() require("harpoon.ui").nav_file(2) end, opts)
keymap.set("n", "<leader>hl", function() require("harpoon.ui").nav_file(3) end, opts)
keymap.set("n", "<leader>h;", function() require("harpoon.ui").nav_file(4) end, opts)

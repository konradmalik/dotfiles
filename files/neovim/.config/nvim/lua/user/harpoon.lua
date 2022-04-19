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
keymap.set("n", "<leader>hj", require("harpoon.ui").nav_file, opts)
keymap.set("n", "<leader>hk", require("harpoon.ui").nav_file, opts)
keymap.set("n", "<leader>hl", require("harpoon.ui").nav_file, opts)
keymap.set("n", "<leader>h;", require("harpoon.ui").nav_file, opts)

local harpoon_ok, harpoon = pcall(require, "harpoon")
if not harpoon_ok then
    vim.notify("cannot load harpoon")
    return
end

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

harpoon.setup()
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

keymap.set("n", "<leader>ha", harpoon_mark.add_file, opts)
keymap.set("n", "<leader>ht", harpoon_ui.toggle_quick_menu, opts)
keymap.set("n", "<leader>hj", function() harpoon_ui.nav_file(1) end, opts)
keymap.set("n", "<leader>hk", function() harpoon_ui.nav_file(2) end, opts)
keymap.set("n", "<leader>hl", function() harpoon_ui.nav_file(3) end, opts)
keymap.set("n", "<leader>h;", function() harpoon_ui.nav_file(4) end, opts)

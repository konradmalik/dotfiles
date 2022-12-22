local harpoon_ok, harpoon = pcall(require, "harpoon")
if not harpoon_ok then
    vim.notify("cannot load harpoon")
    return
end

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Harpoon] " .. desc })
end

harpoon.setup()
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

keymap.set("n", "<leader>ha", harpoon_mark.add_file, opts_with_desc("Add file"))
keymap.set("n", "<leader>ht", harpoon_ui.toggle_quick_menu, opts_with_desc("Toggle Menu"))
keymap.set("n", "<leader>hj", function() harpoon_ui.nav_file(1) end, opts_with_desc("Go to 1"))
keymap.set("n", "<leader>hk", function() harpoon_ui.nav_file(2) end, opts_with_desc("Go to 2"))
keymap.set("n", "<leader>hl", function() harpoon_ui.nav_file(3) end, opts_with_desc("Go to 3"))
keymap.set("n", "<leader>h;", function() harpoon_ui.nav_file(4) end, opts_with_desc("Go to 4"))

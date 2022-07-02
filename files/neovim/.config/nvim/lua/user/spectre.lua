local spectre_ok, spectre = pcall(require, "spectre")
if not spectre_ok then
    vim.notify("cannot load spectre")
    return
end

spectre.setup({
    default = {
        find = {
            --pick one of item in find_engine
            cmd = "rg",
            options = { "ignore-case" }
        },
        replace = {
            --pick one of item in replace_engine
            cmd = "sed"
        }
    },
})

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>S", spectre.open, opts)
keymap.set("n", "<leader>sw", function() spectre.open_visual({ select_word = true }) end, opts)
-- has to be as string, needs to happen at the exact same time!
keymap.set("v", "<leader>s", "<ESC><CMD>lua require('spectre').open_visual():CR>", opts)
keymap.set("n", "<leader>sb", spectre.open_file_search, opts)

local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
    vim.notify("cannot load telescope")
    return
end

local themes = require("telescope.themes")

telescope.setup({
    defaults = { file_ignore_patterns = { "node_modules", "vendor" } },
    extensions = {
        ["ui-select"] = { themes.get_dropdown {} },
    },
})
-- To get extensions loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("ui-select")


local keymap = vim.keymap
local opts = { noremap = true, silent = true }

local builtin = require('telescope.builtin')

keymap.set("n", "<leader>ff", builtin.find_files, opts)
keymap.set("n", "<leader>fg", builtin.live_grep, opts)
keymap.set("n", "<leader>fb", builtin.buffers, opts)
keymap.set("n", "<leader>fh", builtin.help_tags, opts)
keymap.set("n", "<leader>fo", builtin.oldfiles, opts)
keymap.set("n", "<leader>fr", builtin.lsp_references, opts)
keymap.set("n", "<leader>fp", builtin.lsp_implementations, opts)
keymap.set("n", "<leader>fd", builtin.lsp_definitions, opts)
-- git
keymap.set("n", "<leader>go", builtin.git_status, opts)
keymap.set("n", "<leader>gb", builtin.git_branches, opts)
keymap.set("n", "<leader>gc", builtin.git_commits, opts)
-- extensions
keymap.set("n", "<leader>ft", telescope.extensions.file_browser.file_browser, opts)

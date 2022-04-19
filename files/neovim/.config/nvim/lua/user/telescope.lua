local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
    vim.notify("cannot load telescope")
    return
end

telescope.setup({
    defaults = { file_ignore_patterns = { "node_modules", "vendor" } },
})
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
-- same with the file browser
telescope.load_extension("file_browser")

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "<leader>ff", require('telescope.builtin').find_files, opts)
keymap.set("n", "<leader>fg", require('telescope.builtin').live_grep, opts)
keymap.set("n", "<leader>fb", require('telescope.builtin').buffers, opts)
keymap.set("n", "<leader>fh", require('telescope.builtin').help_tags, opts)
keymap.set("n", "<leader>ft", require('telescope').extensions.file_browser.file_browser, opts)

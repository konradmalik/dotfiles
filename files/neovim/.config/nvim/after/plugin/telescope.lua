local telescope_ok, telescope = pcall(require, "telescope")
if not telescope_ok then
    vim.notify("cannot load telescope")
    return
end

telescope.setup({
    defaults = { file_ignore_patterns = { "node_modules", "vendor" } },
})
-- To get extensions loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("file_browser")
telescope.load_extension("frecency")

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Telescope] " .. desc })
end

local builtin = require('telescope.builtin')

keymap.set("n", "<leader>ff", builtin.find_files, opts_with_desc("Find Files"))
keymap.set("n", "<leader>fg", builtin.live_grep, opts_with_desc("Live Grep"))
keymap.set("n", "<leader>fb", builtin.buffers, opts_with_desc("Buffers"))
keymap.set("n", "<leader>fh", builtin.help_tags, opts_with_desc("Help Tags"))
keymap.set("n", "<leader>fo", builtin.oldfiles, opts_with_desc("Old Files"))
keymap.set("n", "<leader>fr", builtin.lsp_references, opts_with_desc("LSP References"))
keymap.set("n", "<leader>fp", builtin.lsp_implementations, opts_with_desc("LSP Implementations"))
keymap.set("n", "<leader>fd", builtin.lsp_definitions, opts_with_desc("LSP Definitions"))
keymap.set("n", "<leader>fT", builtin.lsp_type_definitions, opts_with_desc("LSP Type Definitions"))
keymap.set("n", "<leader>fq", builtin.diagnostics, opts_with_desc("Diagnostics"))
-- git
keymap.set("n", "<leader>go", builtin.git_status, opts_with_desc("Git status"))
keymap.set("n", "<leader>gb", builtin.git_branches, opts_with_desc("Git branches"))
keymap.set("n", "<leader>gc", builtin.git_commits, opts_with_desc("Git commits"))
-- extensions
keymap.set("n", "<leader>ft", telescope.extensions.file_browser.file_browser, opts_with_desc("File Browser"))
keymap.set("n", "<leader>fc", telescope.extensions.frecency.frecency, opts_with_desc("Frecency"))
local noice_ok, _ = pcall(require, "noice")
if noice_ok then
    keymap.set("n", "<leader>fm", function() vim.cmd("Noice telescope") end, opts_with_desc("Noice"))
end

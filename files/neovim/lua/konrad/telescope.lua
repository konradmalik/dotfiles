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

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Telescope] " .. desc })
end

local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

keymap.set("n", "<leader>ff", builtin.find_files, opts_with_desc("[F]ind [F]iles"))
keymap.set("n", "<leader>fi", builtin.git_files, opts_with_desc("Find (G[i]t) Files"))
keymap.set("n", "<leader>fg", builtin.live_grep, opts_with_desc("Live [G]rep"))
keymap.set('n', '<leader>f/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })
keymap.set("n", "<leader>fb", builtin.buffers, opts_with_desc("[B]uffers"))
keymap.set("n", "<leader>fh", builtin.help_tags, opts_with_desc("[H]elp Tags"))
keymap.set("n", "<leader>fo", builtin.oldfiles, opts_with_desc("[O]ld Files"))
keymap.set("n", "<leader>fr", builtin.lsp_references, opts_with_desc("LSP [R]eferences"))
keymap.set("n", "<leader>fp", builtin.lsp_implementations, opts_with_desc("LSP Im[p]lementations"))
keymap.set("n", "<leader>fd", builtin.lsp_definitions, opts_with_desc("LSP [D]efinitions"))
keymap.set("n", "<leader>fT", builtin.lsp_type_definitions, opts_with_desc("LSP [T]ype Definitions"))
keymap.set("n", "<leader>fq", builtin.diagnostics, opts_with_desc("Diagnostics"))
keymap.set("n", "<leader>fc", builtin.resume, opts_with_desc("Resume previous panel"))
-- git
keymap.set("n", "<leader>go", builtin.git_status, opts_with_desc("Git status"))
keymap.set("n", "<leader>gb", builtin.git_branches, opts_with_desc("Git [b]ranches"))
keymap.set("n", "<leader>gc", builtin.git_commits, opts_with_desc("Git [c]ommits"))
-- end

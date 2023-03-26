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

local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[Telescope] " .. desc })
end

local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

vim.keymap.set("n", "<leader>ff", builtin.find_files, opts_with_desc("[F]ind [F]iles"))
vim.keymap.set("n", "<leader>fi", builtin.git_files, opts_with_desc("Find (G[i]t) Files"))
vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts_with_desc("Live [G]rep"))
vim.keymap.set('n', '<leader>f/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, opts_with_desc('[/] Fuzzily search in current buffer'))
vim.keymap.set("n", "<leader>fb", builtin.buffers, opts_with_desc("[B]uffers"))
vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts_with_desc("[H]elp Tags"))
vim.keymap.set("n", "<leader>fq", builtin.diagnostics, opts_with_desc("Diagnostics"))
vim.keymap.set("n", "<leader>fl", builtin.resume, opts_with_desc("Resume [l]ast panel"))
vim.keymap.set("n", "<leader>fc", builtin.commands, opts_with_desc("Find [C]ommands"))
vim.keymap.set("n", "<leader>fm", builtin.keymaps, opts_with_desc("Find key[m]aps"))
-- git
vim.keymap.set("n", "<leader>go", builtin.git_status, opts_with_desc("Git status"))
vim.keymap.set("n", "<leader>gb", builtin.git_branches, opts_with_desc("Git [b]ranches"))
vim.keymap.set("n", "<leader>gc", builtin.git_commits, opts_with_desc("Git [c]ommits"))
-- end

-- impatient needs to be the first
require("konrad.impatient")

-- filetype.lua detection
vim.g.do_filetype_lua = 1
-- to disable filetype.vim and use only filetype.lua (at your own risk), you can add the following to your init.vim:
-- vim.g.did_load_filetypes = 0

require("konrad.globals")
require("konrad.disable_builtin")

require("konrad.plugins")

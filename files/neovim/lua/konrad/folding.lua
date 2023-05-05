local icons = require("konrad.icons")

-- keep foldcolumn on by default
vim.wo.foldcolumn = "1"
-- custom icons for foldcolumn
vim.o.fillchars = "eob: ,fold: ,foldopen:" ..
    icons.ui.FoldOpen .. ",foldsep:" .. icons.ui.Guide .. ",foldclose:" .. icons.ui.FoldClosed
-- treesitter based folding
vim.wo.foldmethod = "indent"
-- treesitter based folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- needs to be set to a high value to not fold everything at start
vim.wo.foldlevel = 99

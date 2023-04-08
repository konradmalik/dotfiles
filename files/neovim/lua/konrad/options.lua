local icons = require("konrad.icons").characters

-- [[ Setting options ]]
-- See `:help vim.o`
-- use spaces instead of tabs. Mostly useful for new files not in repos/isolated files etc.
-- this happens rarely but happens. Most often I use either vim-sleuth (existing file/project)
-- and/or .editorconfig (neovim loads it automatically)
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
-- Set highlight on search. Use :noh to disable until next search
vim.o.hlsearch = true
-- Make line numbers default
vim.wo.number = true
-- Relative line numbers
vim.wo.relativenumber = true
-- incrementally search
vim.o.incsearch = true
-- Enable mouse mode
vim.o.mouse = 'a'
-- Enable break indent
vim.o.breakindent = true
-- don't create a swapfile
vim.o.swapfile = false
-- don't create a backup file
vim.o.backup = false
-- when a file was modified outside of vim and not modified in vim, we can read it automatically
vim.bo.autoread = true;
-- Save undo history
vim.o.undofile = true
vim.o.undodir = "/tmp/.vim-undo"
-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
-- show some hidden chars
vim.o.list = true
vim.o.listchars = table.concat({
    "trail:" .. icons.Trail, "tab:" .. icons.Tab .. "-" .. icons.Tab,
    "nbsp:" .. icons.Nbsp2, "extends:" .. icons.SlopeDown,
    "precedes:" .. icons.SlopeUp
}, ",")
-- Lines of context when scrolling
vim.o.scrolloff = 8
-- Columns of context when scrolling
vim.o.sidescrolloff = 8
-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
-- True color support
vim.o.termguicolors = true
-- highlight the current line
vim.o.cursorline = true
-- use ripgrep as grep program if available
if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

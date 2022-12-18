local fn = vim.fn -- call Vim functions
local g = vim.g -- global variables
local opt = vim.opt -- global/buffer/windows-scoped options

-- treesitter highlighting for lua
g.ts_highlight_lua = true
if fn.executable("rg") then
    opt.grepprg = "rg --vimgrep --no-heading --smart-case"
    opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end
opt.mouse = "" -- disable mouse
opt.fileencoding = "utf-8" -- the encoding written to a file
opt.inccommand = "nosplit" -- live preview when search/replace
opt.hlsearch = true -- :noh by default on or off
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically
opt.autoindent = true -- Insert indents automatically
opt.ignorecase = true -- Ignore case
opt.joinspaces = false -- No double spaces with join after a dot
opt.shiftround = true -- Round indent
opt.scrolloff = 8 -- Lines of context
opt.sidescrolloff = 8 -- Columns of context
opt.smartcase = true -- Don't ignore case with capitals
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.termguicolors = true -- True color support
opt.showcmd = true
opt.cmdheight = 1 -- more space in the neovim command line for displaying messages
opt.wildmode = "list:longest" -- Command-line completion mode
opt.list = true -- Show some invisible characters (tabs...)
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.wrap = false -- no line wrapping
opt.updatetime = 250 -- faster completion (4000ms default)
opt.swapfile = false -- creates a swapfile
opt.backup = false -- creates a backup file
opt.undofile = true
opt.undodir = "/tmp/.vim-undo"
opt.conceallevel = 0 -- so that `` is visible in markdown files
opt.showmode = false -- we don't need to see things like -- INSERT -- anymore
opt.showtabline = 1 -- always show tabs
opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.cursorline = true -- highlight the current line
opt.ruler = false
opt.laststatus = 3 -- global statusline
opt.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
opt.completeopt = 'menuone,noselect'

opt.shortmess:append "c" -- Don't show the dumb matching stuff.
-- opt.shortmess:append "I" -- Disable intro message
opt.whichwrap:append("<,>,[,]")
opt.iskeyword:remove("-")
opt.iskeyword:remove("_")

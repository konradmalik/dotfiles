local cmd = vim.cmd     				-- execute Vim commands
local fn = vim.fn       				-- call Vim functions
local g = vim.g         				-- global variables
local opt = vim.opt         		-- global/buffer/windows-scoped options

vim.cmd [[
    filetype plugin indent on
    autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
]]                                                          -- fix indents (2 spaces) for yaml

local indent = 4
g.nomodeline=true                                       -- disable modelines for security and because we dont need them
if fn.executable("rg") then
    opt.grepprg='rg --vimgrep --no-heading --smart-case'
    opt.grepformat='%f:%l:%c:%m,%f:%l:%m'
end
opt.lazyredraw = true     -- faster scrolling
opt.expandtab = true                           -- Use spaces instead of tabs
opt.smartindent=true                         -- Insert indents automatically
opt.autoindent=true                          -- Insert indents automatically
opt.shiftwidth=indent                        -- Size of an indent
opt.tabstop=indent                           -- Number of spaces tabs count for
opt.softtabstop=indent                       -- Number of spaces tabs count for
opt.hidden=true                              -- Enable modified buffers in background
opt.ignorecase=true                          -- Ignore case
opt.joinspaces=false                         -- No double spaces with join after a dot
opt.scrolloff= 4                             -- Lines of context
opt.shiftround=true                          -- Round indent
opt.sidescrolloff=8                          -- Columns of context
opt.smartcase=true                           -- Don't ignore case with capitals
opt.splitbelow=true                          -- Put new windows below current
opt.splitright=true                          -- Put new windows right of current
opt.termguicolors=false                      -- True color support (does not work for macos)
opt.wildmode='list:longest'                  -- Command-line completion mode
opt.list=true                                -- Show some invisible characters (tabs...)
opt.number=true                              -- Print line number
opt.relativenumber=true                      -- Relative line numbers

-- disable builtins plugins
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin] = 1
end

-- disable nvim intro
opt.shortmess:append "sI"
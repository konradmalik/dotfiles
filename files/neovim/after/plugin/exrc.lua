-- TODO deprecate after nvim 0.9
-- just 'vim.o.exrc = true'
local exrc_ok, exrc = pcall(require, "exrc")
if not exrc_ok then
    vim.notify("cannot load exrc")
    return
end
-- disable built-in local config file support
vim.o.exrc = false

exrc.setup({
    files = { ".exrc", ".nvimrc", ".nvim.lua" },
})

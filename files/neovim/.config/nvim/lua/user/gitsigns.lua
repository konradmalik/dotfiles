local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    vim.notify("gitsigns cannot be initialized!")
    return
end

gitsigns.setup({})

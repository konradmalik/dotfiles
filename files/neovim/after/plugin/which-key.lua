local which_key_ok, which_key = pcall(require, "which-key")
if not which_key_ok then
    vim.notify("cannot load which-key")
    return
end

which_key.setup({
    disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
    }
})

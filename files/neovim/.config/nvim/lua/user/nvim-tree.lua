local nvim_tree_ok, nvim_tree = pcall(require, "nvim-tree")
if not nvim_tree_ok then
    vim.notify("cannot load nvim_tree")
    return
end

nvim_tree.setup({
    disable_netrw = true,
    diagnostics = {
        enable = true,
    },
    git = {
        ignore = false,
    },
    view = {
        adaptive_size = false,
    },
    filters = {
        dotfiles = false,
    },
})

local treesitter_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not treesitter_ok then
    vim.notify("cannot load treesitter")
    return
end

treesitter.setup({
    ensure_installed = "all",
    ignore_install = {},
    sync_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
})

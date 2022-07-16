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
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
})

-- maybe use UFO? https://github.com/kevinhwang91/nvim-ufo
-- treesitter based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- this means - open all unfolded by default
vim.opt.foldenable = false
-- vim.opt.foldlevel = 99

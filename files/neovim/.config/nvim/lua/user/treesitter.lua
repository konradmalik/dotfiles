require('nvim-treesitter.configs').setup {
    ensure_installed = "maintained",
    ignore_install = { },
    sync_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
        disable = {
            -- until https://github.com/nvim-treesitter/nvim-treesitter/issues/1136
            "yaml",
            "python",
        },
    },
}

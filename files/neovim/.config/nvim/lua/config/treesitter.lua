require('nvim-treesitter.configs').setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { }, -- List of parsers to ignore installing
    sync_install = false,
    highlight = {
        enable = true,              -- false will disable the whole extension
        disable = { },              -- list of language that will be disabled
        additional_vim_regex_highlighting = false,
    },
    autotag = {
        enable = true
    },
    autopairs = {
        enable = true
    },
    indent = {
        enable = true             -- experimental, does not work well
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
}

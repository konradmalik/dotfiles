-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require("null-ls")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
    sources = {
        formatting.prettier,
        formatting.terraform_fmt,
        formatting.shfmt,
        diagnostics.shellcheck,
    },
}

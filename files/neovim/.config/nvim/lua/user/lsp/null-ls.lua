-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require("null-ls")

local on_attach = require("user.lsp.handlers").on_attach
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
    on_attach = on_attach,
    sources = {
        formatting.prettier,
        formatting.terraform_fmt,
        formatting.shfmt,
        diagnostics.shellcheck,
    },
}

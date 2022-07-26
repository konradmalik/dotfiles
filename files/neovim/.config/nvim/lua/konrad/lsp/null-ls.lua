-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls_ok, null_ls = pcall(require, "null-ls")
if not null_ls_ok then
    vim.notify("cannot load null-ls")
    return
end
local handlers = require("konrad.lsp.handlers")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions


null_ls.setup({
    sources = {
        formatting.prettier,
        formatting.terraform_fmt,
        formatting.shfmt,
        formatting.black,
        formatting.isort,
        diagnostics.mypy,
        diagnostics.shellcheck,
        code_actions.gitsigns,
    },
    -- required to properly register keymaps etc.
    on_attach = handlers.on_attach,
})

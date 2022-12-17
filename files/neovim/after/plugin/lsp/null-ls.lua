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
        -- always available
        formatting.prettier,
        formatting.shfmt,

        diagnostics.shellcheck,

        code_actions.gitsigns,

        -- per project
        formatting.black,
        formatting.isort,
        formatting.terraform_fmt,

        diagnostics.mypy,
    },
    -- required to properly register keymaps etc.
    on_attach = handlers.on_attach,
})

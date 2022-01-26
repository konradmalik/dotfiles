-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls = require("null-ls")
local lsp_handlers = require("user.lsp.handlers")

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	sources = {
		formatting.prettier,
		formatting.terraform_fmt,
		formatting.shfmt,
		formatting.stylua,
		diagnostics.shellcheck,
	},
    -- required to properly register keymaps
    -- all because null-ls is not recognized (installed) by lsp installer
    on_attach = lsp_handlers.on_attach,
})

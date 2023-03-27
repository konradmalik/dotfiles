-- https://github.com/jose-elias-alvarez/null-ls.nvim
local null_ls_ok, null_ls = pcall(require, "null-ls")
if not null_ls_ok then
    vim.notify("cannot load null-ls")
    return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

-- null_ls has a 'should_attach' fuction where we could limit
-- the number of buffers it attaches to but we need it in all buffers in
-- fact due to gitsigns
null_ls.setup({
    sources = {
        -- always available
        formatting.prettier,
        formatting.shfmt,

        diagnostics.shellcheck,

        code_actions.gitsigns,
        -- per project can be added in .nvim.lua via "register" function
        -- which takes a table of sources
    },
})

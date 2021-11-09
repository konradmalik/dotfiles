local lspconfig = require('lspconfig')
local completion = require('completion')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- capabilites for cmp
-- add it to each server you want
local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

local on_attach = function(client, bufnr)
  -- set options etc for lsp
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

-- https://github.com/microsoft/pyright
lspconfig.pyright.setup {
    on_attach = on_attach,
    init_options = { provideFormatter = true },
    capabilites = capabilities,
}

-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilites = capabilities,
}

-- https://github.com/rust-analyzer/rust-analyzer
lspconfig.rust_analyzer.setup {
    on_attach = on_attach,
    init_options = { provideFormatter = true },
    capabilites = capabilities,
}

-- prettier setup
local format_options_prettier = {
    tabWidth = 4,
    singleQuote = true,
    trailingComma = "all",
    configPrecedence = "prefer-file"
}
vim.g.format_options_json = format_options_prettier
vim.g.format_options_yaml = format_options_prettier
vim.g.format_options_markdown = format_options_prettier

local black = require("config/efm/black")
local autopep8 = require("config/efm/autopep8")
local goimports = require("config/efm/goimports")
local prettier = require("config/efm/prettier")
local languages = {
    python = {black,  autopep8 },
    go = { goimports },
    yaml = { prettier },
    json = { prettier },
    markdown = { prettier },
}
-- https://github.com/mattn/efm-langserver
lspconfig.efm.setup {
    on_attach = on_attach,
    init_options = {
        documentFormatting = true,
    },
    capabilites = capabilities,
    filetypes = vim.tbl_keys(languages),
    settings = {
        languages = languages,
    }
}

local lspconfig = require('lspconfig')
local handlers = require("user.lsp.handlers")

-- https://github.com/rust-analyzer/rust-analyzer
lspconfig.rust_analyzer.setup {
    on_attach = handlers.on_attach,
    capabilites = handlers.capabilities,
}


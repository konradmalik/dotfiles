local lspconfig = require('lspconfig')
local handlers = require("user.lsp.handlers")
-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup {
    on_attach = handlers.on_attach,
    capabilites = handlers.capabilities,
}

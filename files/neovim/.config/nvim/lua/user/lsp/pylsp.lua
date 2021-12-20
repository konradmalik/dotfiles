local lspconfig = require('lspconfig')
local handlers = require("user.lsp.handlers")
-- https://github.com/python-lsp/python-lsp-server
lspconfig.pylsp.setup{
    on_attach = handlers.on_attach,
    init_options = { provideFormatter = true },
    capabilites = handlers.capabilities,
    settings = {
        pylsp = {
            plugins = {
                pylsp_mypy = {
                    enabled = true,
                    live_mode = true,
                    dmypy = false,
                },
                pylsp_black = {
                    enabled = true,
                },
                pyls_isort = {
                    enabled = true
                },
            }
        }
    }
}

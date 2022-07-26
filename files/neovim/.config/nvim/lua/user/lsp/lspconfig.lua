local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
    vim.notify("mason-lspconfig cannot be initialized!")
    return
end


local servers = {
    "sumneko_lua", -- called lua-language-server now
    "gopls",
    "pyright",
    "rust_analyzer",
    "yamlls"
}

mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,
})

local lspconfig = require("lspconfig")
local lsp_handlers = require("user.lsp.handlers")

for _, server in ipairs(servers) do
    local found, server_settings = pcall(require, "user.lsp.settings." .. server)
    if not found then
        server_settings = { settings = {} }
    end

    lspconfig[server].setup({
        on_attach = lsp_handlers.on_attach,
        capabilities = lsp_handlers.capabilities,
        settings = server_settings.settings,
    })
end

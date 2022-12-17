local lspconfig = require("lspconfig")
local lsp_handlers = require("konrad.lsp.handlers")

local servers = {
    -- always available
    -- none
    -- per project
    "sumneko_lua", -- called lua-language-server now
    "rnix",
    "yamlls",
    "gopls",
    "pyright",
    "omnisharp",
    "rust_analyzer",
}

for _, server in ipairs(servers) do
    local found, server_setup_overrides = pcall(require, "konrad.lsp.settings." .. server)
    if not found then
        server_setup_overrides = {}
    end

    local base_table = {
        on_attach = lsp_handlers.on_attach,
        capabilities = lsp_handlers.capabilities,
    }

    local overrides_table = server_setup_overrides
    local merged_table = vim.tbl_deep_extend("force", base_table, overrides_table)

    lspconfig[server].setup(merged_table)
end

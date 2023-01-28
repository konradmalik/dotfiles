local lspconfig = require("lspconfig")
local lsp_handlers = require("konrad.lsp.handlers")

local function has_bins(...)
    for i = 1, select("#", ...) do
        if 0 == vim.fn.executable((select(i, ...))) then
            return false
        end
    end
    return true
end

local servers = {
    -- always available
    -- none
    -- per project
    "gopls",
    "nil_ls",
    "omnisharp",
    "pyright",
    "rust_analyzer",
    "sumneko_lua", -- called lua-language-server now
    "terraformls",
    "yamlls",
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

    -- only setup server if binary is present, this avoids annoying messages
    -- evaluate this, may not be worth the startup penalty
    -- local cmd = lspconfig[server].document_config.default_config["cmd"] or merged_table["cmd"]
    -- if has_bins(cmd[1]) then
    lspconfig[server].setup(merged_table)
    -- end
end

local utils = require('konrad.utils')

---@param config table
---@return boolean
local function is_matching_filetype(config)
    local ft = vim.bo.filetype or ''
    return ft ~= '' and utils.has_value(config.filetypes or {}, ft)
end

-- if add is called rather late, after the file is opened, then the configured server won't start for the current buffer
-- solution is to check if we currently have a buffer and if it matches configure filetype
---@param config table
---@return nil
local function start_if_needed(config)
    -- this can only even happen for the very first buffer after opening
    if vim.api.nvim_get_current_buf() ~= 1 then
        return
    end
    -- make sure no already attached
    if #vim.lsp.get_active_clients(config) > 0 then
        return
    end
    -- launch if matching filetype
    if is_matching_filetype(config) then
        config.launch()
    end
end

local M = {}

--- Configure server by name, useful for per-project .nvim.lua files.
--- Can be called whenever.
---
---Common examples:
---      - ansiblels
---      - gopls
---      - jsonls
---      - nil_ls
---      - omnisharp
---      - pyright
---      - rust_analyzer
---      - lua_ls
---      - terraformls
---      - yamlls
---
---@param server string any server name from nvim-lspconfig.
---@param opts table|nil options you would pass to lspconfig.setup(opts), will override base settings
---@return nil
M.add = function(server, opts)
    local lspconfig = require("lspconfig")
    local capabilities = require("konrad.lsp.capabilities")

    local found, overrides = pcall(require, "konrad.lsp.settings." .. server)
    if not found then
        overrides = {}
    end

    local base = {
        capabilities = capabilities,
    }

    local merged = vim.tbl_deep_extend("force", base, overrides, opts or {})
    local config = lspconfig[server]
    config.setup(merged)
    start_if_needed(config)
end

M.setup = function()
    require("konrad.lsp.fidget")
    require("konrad.lsp.null-ls")
    require("konrad.lsp.attach")
end

return M

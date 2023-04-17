local utils = require('konrad.utils')
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
    if utils.is_matching_filetype(config) then
        config.launch()
    end
end

local add_lspconfig = function(server, opts)
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

local add_null_ls = function(sources)
    require('null-ls').register(sources)
end

local M = {}

--- Configure lsp server, useful for per-project .nvim.lua files.
--- Can be called whenever. Works for lsp and null-ls currently.
---
--- Common examples for LSP:
---      - ansiblels
---      - csharp_ls
---      - gopls
---      - jsonls
---      - nil_ls
---      - omnisharp
---      - pyright
---      - rust_analyzer
---      - lua_ls
---      - terraformls
---      - yamlls
--
--- Common examples for null-ls:
---      - require('null-ls').builtins.formatting.black
---      - require('null-ls').builtins.formatting.isort
---      - require('null-ls').builtins.formatting.nixpkgs_fmt
---      - require('null-ls').builtins.formatting.terraform_fmt
---      - require('null-ls').builtins.diagnostics.mypy.with({
---            condition = function(utils)
---                return kutils.has_bins("mypy")
---            end
---        })
---      - require('null-ls').builtins.diagnostics.vale.with({
---            condition = function(utils)
---                return kutils.has_bins("vale")
---            end
---        })
---
---@param server string any server name from nvim-lspconfig or 'null-ls' if this adds a null-ls source.
---@param opts table|nil
--- options you would pass to lspconfig.setup(opts), will override base settings
--- or if server is 'null-ls', then source(s) config as a table
---@return nil
M.add = function(server, opts)
    if server == 'null-ls' then
        add_null_ls(opts)
        return
    else
        add_lspconfig(server, opts)
        return
    end
end

M.setup = function()
    require("konrad.lsp.fidget")
    require("konrad.lsp.null-ls")
    require("konrad.lsp.attach")
end

return M

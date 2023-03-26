local M = {}

local configs = {}

--- Configure DAP by name, useful for per-project .nvim.lua files.
--- Must be called before init. This works because I don't initialize DAP
---at start, but on demand via DapEnable command.
---
---Built-in names:
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param config string|function config name or function with no arguments if custom config
---@return nil
M.add = function(config)
    table.insert(configs, config)
end

M.setup = function()
    require("konrad.dap.ui")
    require("konrad.dap.virtual-text")
    require("konrad.dap.keymaps")

    for _, config in ipairs(configs) do
        if type(config) == "string" then
            local found, _ = pcall(require, "konrad.dap.configurations." .. config)
            if not found then
                vim.notify("could not find DAP config for " .. config)
            end
        elseif type(config) == "function" then
            config()
        else
            vim.notify("bad type for config: " .. vim.inspect(config))
        end

    end
end

return M

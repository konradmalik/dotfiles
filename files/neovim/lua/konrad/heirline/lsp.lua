local conditions = require("heirline.conditions")
local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

local M = {}

M.LSPActive = {
    condition = conditions.lsp_attached,
    update = { 'LspAttach', 'LspDetach' },
    on_click = {
        callback = function()
            vim.defer_fn(function()
                vim.cmd("LspInfo")
            end, 100)
        end,
        name = "heirline_LSP",
    },

    -- Or complicate things a bit and get the servers names
    provider = function()
        local names = {}
        for _, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
        end
        return icons.ui.Gear .. " [" .. table.concat(names, " ") .. "]"
    end,
    hl       = { fg = colors.green, bold = true },
}

return M

local conditions = require("heirline.conditions")
local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

local M = {}

M.LSPActive = {
    condition = conditions.lsp_attached,
    update = { 'LspAttach', 'LspDetach' },
    on_click = {
        callback = function()
            vim.cmd("LspInfo")
        end,
        name = "heirline_LSP",
    },

    static = {
        max_part_taken = 0.15,
        lbr = "[",
        rbr = "]",
    },

    init = function(self)
        self.clients = vim.lsp.get_active_clients({ bufnr = 0 })
    end,

    provider = function(self)
        local names = {}
        for _, server in pairs(self.clients) do
            table.insert(names, server.name)
        end
        local prefix = #self.clients > 1 and icons.ui.Gears or icons.ui.Gear
        local banner = table.concat({ prefix, " ", self.lbr, table.concat(names, " "), self.rbr })
        -- hide if to big compared to the whole bar
        if not conditions.width_percent_below(#banner, 0.15) then
            banner = table.concat({ prefix, " ", self.lbr, #self.clients, self.rbr })
        end
        return banner
    end,
    hl = { fg = colors.green, bold = true },
}

return M

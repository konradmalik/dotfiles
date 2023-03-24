local conditions = require("heirline.conditions")
local icons = require('konrad.icons')
local colors = require('konrad.heirline.colors')

local M = {}
M.WorkingDir = {
    provider = function()
        local icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " " .. icons.documents.Folder .. " "
        local cwd = vim.fn.getcwd(0)
        cwd = vim.fn.fnamemodify(cwd, ":~")
        if not conditions.width_percent_below(#cwd, 0.25) then
            cwd = vim.fn.pathshorten(cwd)
        end
        local trail = cwd:sub(-1) == '/' and '' or "/"
        return icon .. cwd .. trail
    end,
    hl = { fg = colors.blue, bold = true },
}

M.WorkingDirFlexible = {
    init = function(self)
        self.icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " " .. icons.documents.Folder .. " "
        local cwd = vim.fn.getcwd(0)
        self.cwd = vim.fn.fnamemodify(cwd, ":~")
    end,
    hl = { fg = colors.blue, bold = true },

    flexible = 1,

    {
        -- evaluates to the full-lenth path
        provider = function(self)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return self.icon .. self.cwd .. trail .. " "
        end,
    },
    {
        -- evaluates to the shortened path
        provider = function(self)
            local cwd = vim.fn.pathshorten(self.cwd)
            local trail = self.cwd:sub(-1) == "/" and "" or "/"
            return self.icon .. cwd .. trail .. " "
        end,
    },
    {
        -- evaluates to "", hiding the component
        provider = "",
    }
}
return M

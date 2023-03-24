local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local devicons = require("nvim-web-devicons")
local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')
local primitives = require('konrad.heirline.primitives')

local M = {}

M.FileNameBlock = {
    init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
    end,
}

-- We can now define some children separately and add them later
M.FileIcon = {
    init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color = devicons.get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
        return self.icon and (self.icon .. " ")
    end,
    hl = function(self)
        return { fg = self.icon_color }
    end
}

M.FileName = {
    provider = function(self)
        -- first, trim the pattern relative to the current directory. For other
        -- options, see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ":.")
        if filename == "" then return "[No Name]" end
        -- now, if the filename would occupy more than 1/4th of the available
        -- space, we trim the file path to its initials
        -- See Flexible Components section for dynamic stuff
        if not conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
        end
        return filename
    end,
    hl = function()
        if vim.bo.modified then
            -- use `force` because we need to override the child's hl foreground
            return { fg = colors.cyan, bold = true, force = true }
        end
        return { fg = colors.directory }
    end,
}

M.FileFlags = {
    {
        condition = function()
            return vim.bo.modified
        end,
        provider = icons.ui.SmallCircle,
        hl = { fg = colors.green },
    },
    {
        condition = function()
            return vim.bo.readonly
        end,
        provider = icons.ui.Lock,
        hl = { fg = colors.orange },
    },
    {
        condition = function()
            return not vim.bo.modifiable
        end,
        provider = icons.ui.FilledLock,
        hl = { fg = colors.red },
    },
}

M.HelpFileName = {
    condition = function()
        return vim.bo.filetype == "help"
    end,
    provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        return vim.fn.fnamemodify(filename, ":t")
    end,
    hl = { fg = colors.blue },
}

M.FileNameFlexible = {
    init = function(self)
        self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
        if self.lfilename == "" then self.lfilename = "[No Name]" end
    end,
    hl = function()
        if vim.bo.modified then
            -- use `force` because we need to override the child's hl foreground
            return { fg = colors.cyan, bold = true, force = true }
        end
    end,
    flexible = 2,

    {
        provider = function(self)
            return self.lfilename
        end,
    },
    {
        provider = function(self)
            return vim.fn.pathshorten(self.lfilename)
        end,
    },
}

-- let's add the children to our FileNameBlock component
M.FileNameBlock = utils.insert(M.FileNameBlock,
    M.FileIcon,
    M.FileNameFlexible,
    M.FileFlags,
    primitives.Cut
)

return M

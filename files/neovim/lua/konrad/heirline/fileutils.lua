local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

local M = {}

M.FileType = {
    provider = function()
        return vim.bo.filetype
    end,
    hl = { fg = colors.filetype, bold = true },
}

M.FileEncoding = {
    provider = function()
        local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
        return enc:lower()
    end,
    hl = { fg = colors.gray },
}

M.FileFormat = {
    static = {
        format_types = {
            unix = icons.oss.Linux,
            mac = icons.oss.Mac,
            dos = icons.oss.Windows,
        },
    },
    provider = function(self)
        local fmt = vim.bo.fileformat
        return self.format_types[fmt]
    end
}

M.FileSize = {
    provider = function()
        -- stackoverflow, compute human readable file size
        local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
        local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
        fsize = (fsize < 0 and 0) or fsize
        if fsize < 1024 then
            return fsize .. suffix[1]
        end
        local i = math.floor((math.log(fsize) / math.log(1024)))
        return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
    end
}

M.FileLastModified = {
    -- did you know? Vim is full of functions!
    provider = function()
        local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
        return (ftime > 0) and os.date("%c", ftime)
    end
}

return M

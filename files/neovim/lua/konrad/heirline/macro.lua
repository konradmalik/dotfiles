local utils = require("heirline.utils")
local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

return {
    condition = function()
        return vim.fn.reg_recording() ~= "" and vim.o.cmdheight == 0
    end,
    provider = icons.ui.CircleDot .. " ",
    hl = { fg = colors.orange, bold = true },
    utils.surround({ "[", "]" }, nil, {
        provider = function()
            return vim.fn.reg_recording()
        end,
        hl = { fg = colors.green, bold = true },
    }),
    update = {
        "RecordingEnter",
        "RecordingLeave",
        -- redraw the statusline on recording events
        callback = vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
        end),
    }
}

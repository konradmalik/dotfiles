local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

return {
    condition = function()
        local ok, _ = pcall(require, "dap")
        return ok
    end,
    provider = function()
        return icons.ui.Bug .. " " .. require('dap').status()
    end,
    hl = colors.debug
    -- see Click-it! section for clickable actions
}

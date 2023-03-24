local colors = require('konrad.heirline.colors')
local icons = require('konrad.icons')

return {
    provider = icons.ui.Laptop .. " " .. vim.fn.hostname(),
    hl = { fg = colors.blue },
}

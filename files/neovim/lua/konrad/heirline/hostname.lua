local colors = require('konrad.heirline.colors')

return {
    provider = vim.fn.hostname(),
    hl = { fg = colors.blue },
}

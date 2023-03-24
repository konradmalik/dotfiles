local colors = require('konrad.heirline.colors')

return {
    -- %l = current line number
    -- %L = number of lines in the buffer
    -- %c = column number
    -- %P = percentage through file of displayed window
    provider = "[%7(%l/%3L%):%2c %P]",
    hl = { fg = colors.purple },
}

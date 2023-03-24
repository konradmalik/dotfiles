local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

return {
    static = {
        sbar = icons.ui.Animations.ThinFill,
    },
    provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(0)[1]
        local lines = vim.api.nvim_buf_line_count(0)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = colors.blue, bg = colors.bright_bg },
}

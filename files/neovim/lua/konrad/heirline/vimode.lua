local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

return {
    init = function(self)
        self.mode = vim.fn.mode(1)
        if not self.once then
            vim.cmd("au ModeChanged *:*o redrawstatus")
        end
        self.once = true
    end,
    static = {
        mode_names = {
            n = "N",
            no = "N?",
            nov = "N?",
            noV = "N?",
            ["no\22"] = "N?",
            niI = "Ni",
            niR = "Nr",
            niV = "Nv",
            nt = "Nt",
            v = "V",
            vs = "Vs",
            V = "V_",
            Vs = "Vs",
            ["\22"] = "^V",
            ["\22s"] = "^V",
            s = "S",
            S = "S_",
            ["\19"] = "^S",
            i = "I",
            ic = "Ic",
            ix = "Ix",
            R = "R",
            Rc = "Rc",
            Rx = "Rx",
            Rv = "Rv",
            Rvc = "Rv",
            Rvx = "Rv",
            c = "C",
            cv = "Ex",
            r = "...",
            rm = "M",
            ["r?"] = "?",
            ["!"] = "!",
            t = "T",
        },
        mode_colors = {
            n = colors.red,
            i = colors.green,
            v = colors.cyan,
            V = colors.cyan,
            ["\22"] = colors.cyan,
            c = colors.orange,
            s = colors.purple,
            S = colors.purple,
            ["\19"] = colors.purple,
            R = colors.orange,
            r = colors.orange,
            ["!"] = colors.red,
            t = colors.green,
        }
    },
    provider = function(self)
        local name = self.mode_names[self.mode] or self.mode
        return icons.misc.Vi .. " %2(" .. name .. "%)"
    end,
    hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.mode_colors[mode], bold = true, }
    end,
    update = { "ModeChanged" },
}

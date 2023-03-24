local M = {}
local colors = require('konrad.heirline.colors')

-- The easy way.
-- navic is lazy, packadded when lsp attaches
M.NavicLite = {
    condition = function()
        local ok, navic = pcall(require, "nvim-navic")
        if not ok then
            return false
        end
        return navic.is_available()
    end,
    provider = function()
        require('nvim-navic').get_location({ highlight = true })
    end,
    update = 'CursorMoved'
}

-- Full nerd (with icon colors and clickable elements)!
-- works in multi window, but does not support flexible components (yet ...)
M.NavicNerd = {
    condition = function()
        local ok, navic = pcall(require, "nvim-navic")
        if not ok then
            return false
        end
        return navic.is_available()
    end,
    static = {
        -- create a type highlight map
        type_hl = {
            File = "Directory",
            Module = "@include",
            Namespace = "@namespace",
            Package = "@include",
            Class = "@structure",
            Method = "@method",
            Property = "@property",
            Field = "@field",
            Constructor = "@constructor",
            Enum = "@field",
            Interface = "@type",
            Function = "@function",
            Variable = "@variable",
            Constant = "@constant",
            String = "@string",
            Number = "@number",
            Boolean = "@boolean",
            Array = "@field",
            Object = "@type",
            Key = "@keyword",
            Null = "@comment",
            EnumMember = "@field",
            Struct = "@structure",
            Event = "@keyword",
            Operator = "@operator",
            TypeParameter = "@type",
        },
        -- bit operation dark magic, see below...
        enc = function(line, col, winnr)
            return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
        end,
        -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
        dec = function(c)
            local line = bit.rshift(c, 16)
            local col = bit.band(bit.rshift(c, 6), 1023)
            local winnr = bit.band(c, 63)
            return line, col, winnr
        end
    },
    init = function(self)
        local data = require('nvim-navic').get_data() or {}
        local children = {}
        -- create a child for each level
        for i, d in ipairs(data) do
            -- encode line and column numbers into a single integer
            local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
            local child = {
                {
                    provider = d.icon,
                    hl = self.type_hl[d.type],
                },
                {
                    -- escape `%`s (elixir) and buggy default separators
                    provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),
                    -- highlight icon only or location name as well
                    -- hl = self.type_hl[d.type],

                    on_click = {
                        -- pass the encoded position through minwid
                        minwid = pos,
                        callback = function(_, minwid)
                            -- decode
                            local line, col, winnr = self.dec(minwid)
                            vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                        end,
                        name = "heirline_navic",
                    },
                },
            }
            -- add a separator only if needed
            if #data > 1 and i < #data then
                table.insert(child, {
                    provider = " > ",
                    hl = { fg = colors.bright_fg },
                })
            end
            table.insert(children, child)
        end
        -- instantiate the new child, overwriting the previous one
        self.child = self:new(children, 1)
    end,
    -- evaluate the children containing navic components
    provider = function(self)
        return self.child:eval()
    end,
    hl = { fg = colors.gray },
    update = 'CursorMoved'
}

M.NavicFlexible = { flexible = 3, M.NavicNerd, { provider = "" } }

return M

local conditions = require("heirline.conditions")
local icons = require("konrad.icons")
local colors = require('konrad.heirline.colors')

-- relies on gitsigns
return {
    condition = conditions.is_git_repo,

    init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
        self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,

    hl = { fg = colors.orange },


    { -- git branch name
        provider = function(self)
            return icons.git.Branch .. " " .. self.status_dict.head
        end,
        hl = { bold = true }
    },
    {
        provider = function(self)
            local count = self.status_dict.added or 0
            return count > 0 and (" " .. icons.git.Add .. " " .. count)
        end,
        hl = colors.git_add,
    },
    {
        provider = function(self)
            local count = self.status_dict.removed or 0
            return count > 0 and (" " .. icons.git.Remove .. " " .. count)
        end,
        hl = colors.git_del,
    },
    {
        provider = function(self)
            local count = self.status_dict.changed or 0
            return count > 0 and (" " .. icons.git.Mod .. " " .. count)
        end,
        hl = colors.git_change
    },
}

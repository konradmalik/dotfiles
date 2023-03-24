local icons = require("konrad.icons")

local M = {}
M.Align = { provider = "%=" }
M.Cut = { provider = '%<' } -- this means that the statusline is cut here when there's not enough space
M.SeparatorLine = { provider = icons.lines.Edge }
M.Space = { provider = " " }
return M

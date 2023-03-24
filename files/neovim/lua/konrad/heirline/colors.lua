vim.cmd("packadd heirline.nvim")

local utils = require("heirline.utils")

-- grabs stuff from the colorscheme, so it needs to be set first
return {
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("NonText").fg,
    orange = utils.get_highlight("Constant").fg,
    purple = utils.get_highlight("Statement").fg,
    cyan = utils.get_highlight("Special").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    git_del = utils.get_highlight("diffRemoved").fg, --diffDeleted
    git_add = utils.get_highlight("diffAdded").fg,
    git_change = utils.get_highlight("diffChanged").fg,
    debug = utils.get_highlight("Debug").fg,
    directory = utils.get_highlight("Directory").fg,
    filetype = utils.get_highlight("Type").fg,
}

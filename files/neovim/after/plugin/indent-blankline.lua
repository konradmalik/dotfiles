local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
    vim.notify("cannot load indent_blankline")
    return
end

local icons = require("konrad.icons").ui

indent_blankline.setup {
    char = icons.Guide,
    show_trailing_blankline_indent = false,
}

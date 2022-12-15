local noice_ok, noice = pcall(require, "noice")
if not noice_ok then
    -- vim.notify("cannot load noice")
    return
end

local ui_icons = require('konrad.icons').ui
local lang_icons = require('konrad.icons').languages

vim.opt.ch = 0 -- hide command-line when 0

noice.setup {
    cmdline = {
        enabled = true, -- enables the Noice cmdline UI
        view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
        format = {
            cmdline = { icon = ui_icons.FoldClosed },
            search_down = { icon = string.format("%s %s", ui_icons.SearchBig, ui_icons.Down) },
            search_up = { icon = string.format("%s %s", ui_icons.SearchBig, ui_icons.Up) },
            filter = { icon = ui_icons.Pencil },
            lua = { icon = lang_icons.Lua },
        },
    },
    messages = {
        enabled = true, -- enables the Noice messages UI
        view = "mini", -- default view for messages
        view_error = "mini", -- view for errors
        view_warn = "mini", -- view for warnings
        view_history = "split", -- view for :messages
        view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
        enabled = true, -- enables the Noice popupmenu UI
        backend = "cmp", -- backend to use to show regular cmdline completions
    },
    history = {
        view = "split",
    },
    -- hijack vim.notify
    notify = {
        enabled = true,
    },
    lsp_progress = {
        enabled = true,
    },
}

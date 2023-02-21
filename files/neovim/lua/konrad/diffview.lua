local status_ok, diffview = pcall(require, "diffview")
if not status_ok then
    vim.notify("diffview cannot be initialized!")
    return
end

-- local actions = require("diffview.actions")
local icons = require("konrad.icons")

diffview.setup({
    enhanced_diff_hl = false, -- See ':h diffview-config-enhanced_diff_hl'
    use_icons = true, -- Requires nvim-web-devicons
    icons = { -- Only applies when use_icons is true.
        folder_closed = icons.documents.Folder,
        folder_open = icons.documents.OpenFolder,
    },
    signs = {
        fold_closed = icons.ui.FoldClosed,
        fold_open = icons.ui.FoldOpen,
        done = icons.ui.Check,
    },
    view = {
        merge_tool = {
            layout = "diff3_mixed",
        }
    },
})

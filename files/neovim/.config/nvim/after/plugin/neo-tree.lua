local neo_tree_ok, neo_tree = pcall(require, "neo-tree")
if not neo_tree_ok then
    vim.notify("cannot load neo-tree")
    return
end

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- nvim tree
keymap.set("n", "<leader>tt", "<cmd>Neotree<cr>", opts)

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local docs_icons = icons.documents
local lines_icons = icons.lines
local ui_icons = icons.ui


-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

vim.fn.sign_define("DiagnosticSignError",
    { text = diag_icons.Error, texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn",
    { text = diag_icons.Warning, texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo",
    { text = diag_icons.Information, texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint",
    { text = diag_icons.Hint, texthl = "DiagnosticSignHint" })

neo_tree.setup({
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    enable_git_status = true,
    enable_diagnostics = true,
    sort_case_insensitive = true, -- used when sorting files and directories in the tree
    default_component_configs = {
        indent = {
            -- indent guides
            with_markers = true,
            indent_marker = lines_icons.Edge,
            last_indent_marker = lines_icons.Corner,
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = ui_icons.FoldClosed,
            expander_expanded = ui_icons.FoldOpen,
            expander_highlight = "NeoTreeExpander",
        },
        icon = {
            folder_closed = docs_icons.Folder,
            folder_open = docs_icons.OpenFolder,
            folder_empty = docs_icons.EmptyFolder,
            default = "*",
            highlight = "NeoTreeFileIcon"
        },
        modified = {
            symbol = ui_icons.Square,
            highlight = "NeoTreeModified",
        },
        name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
        },
        git_status = {
            symbols = {
                -- Change type
                added     = git_icons.Add,
                modified  = git_icons.Mod,
                deleted   = git_icons.Deleted,
                renamed   = git_icons.Rename,
                -- Status type
                untracked = git_icons.Untracked,
                ignored   = git_icons.Ignore,
                unstaged  = git_icons.Unstaged,
                staged    = git_icons.Staged,
                conflict  = git_icons.Unmerged,
            }
        },
    },
    window = {
        width = 40,
        mapping_options = {
            noremap = true,
            nowait = true,
        },
    },
    filesystem = {
        filtered_items = {
            visible = true, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_hidden = true, -- only works on Windows for hidden files/directories
            hide_by_name = {
                --"node_modules"
            },
            hide_by_pattern = { -- uses glob style patterns
                --"*.meta",
                --"*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
                --".gitignored",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                --".DS_Store",
                --"thumbs.db"
            },
            never_show_by_pattern = { -- uses glob style patterns
                ".null-ls_*",
            },
        },
        follow_current_file = false, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
    },
})

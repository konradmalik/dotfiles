-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.g.neo_tree_remove_legacy_commands = 1

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local opts_with_desc = function(desc)
    return vim.tbl_extend("error", opts, { desc = "[NeoTree] " .. desc })
end

keymap.set("n", "<leader>tt", "<cmd>Neotree focus filesystem left toggle<cr>", opts_with_desc("Toggle"))

local neo_tree_ok, neo_tree = pcall(require, "neo-tree")
if not neo_tree_ok then
    vim.notify("cannot load neo-tree")
    return
end

local icons = require("konrad.icons")
local git_icons = icons.git
local docs_icons = icons.documents
local lines_icons = icons.lines
local ui_icons = icons.ui

-- local netman_ok, _ = pcall(require, "netman")
-- if not netman_ok then
--     vim.notify("cannot load netman")
--     return
-- end

neo_tree.setup({
    sources = {
        "filesystem",
        -- "netman.ui.neo-tree",
    },
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
        },
        modified = {
            symbol = ui_icons.Square,
        },
        name = {
            trailing_slash = false,
            use_git_status_colors = true,
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
    },
    filesystem = {
        use_libuv_file_watcher = true,
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
        follow_current_file = true,
    },
})

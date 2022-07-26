local nvim_tree_ok, nvim_tree = pcall(require, "nvim-tree")
if not nvim_tree_ok then
    vim.notify("cannot load nvim_tree")
    return
end

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local docs_icons = icons.documents
local lines_icons = icons.lines

nvim_tree.setup({
    disable_netrw = true,
    diagnostics = {
        enable = true,
        icons = {
            hint = diag_icons.Hint,
            info = diag_icons.Information,
            warning = diag_icons.Warning,
            error = diag_icons.Error,
        },
    },
    git = {
        ignore = false,
    },
    view = {
        adaptive_size = true,
    },
    filters = {
        dotfiles = false,
    },
    renderer = {
        indent_markers = {
            enable = true,
            icons = {
                corner = lines_icons.Corner,
                edge = lines_icons.Edge,
                item = lines_icons.Edge,
                none = " ",
            },
        },
        root_folder_modifier = ':t',
        icons = {
            webdev_colors = true,
            glyphs = {
                default = docs_icons.File,
                symlink = docs_icons.SymlinkFile,
                git = {
                    unstaged = git_icons.Unstaged,
                    staged = git_icons.Staged,
                    unmerged = git_icons.Unmerged,
                    renamed = git_icons.Rename,
                    deleted = git_icons.Remove,
                    untracked = git_icons.Untracked,
                    ignored = git_icons.Ignore,
                },
                folder = {
                    default = docs_icons.Folder,
                    open = docs_icons.OpenFolder,
                    empty = docs_icons.EmptyFolder,
                    empty_open = docs_icons.EmptyOpenFolder,
                    symlink = docs_icons.SymlinkFolder,
                }
            }
        },
    },
})

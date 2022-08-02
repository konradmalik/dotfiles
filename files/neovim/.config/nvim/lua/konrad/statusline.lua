if not pcall(require, "el") then
    return
end

RELOAD "el"
require("el").reset_windows()

local builtin = require "el.builtin"
local extensions = require "el.extensions"
local git = require "el.git"
local sections = require "el.sections"
local subscribe = require "el.subscribe"
local diagnostic = require "el.diagnostic"

local navic_ok, navic = pcall(require, "nvim-navic")

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local ui_icons = icons.ui
local line_icons = icons.lines

local file_icon = subscribe.buf_autocmd("el_file_icon", "BufRead", function(_, bufnr)
    local icon = extensions.file_icon(_, bufnr)
    if icon then
        return icon .. " "
    end

    return ""
end)

local git_branch = subscribe.buf_autocmd("el_git_branch", "BufEnter", function(window, buffer)
    local branch = git.branch(window, buffer)
    if branch then
        return " " .. git_icons.Branch .. " " .. branch
    end
end)

local git_changes = git.make_changes(function(_, _, results)
    if results["new"] then
        return git_icons.Untracked
    elseif results["ignored"] then
        return git_icons.Ignore
    elseif results["inserted"] then
        return string.format("%s %s %s %s",
            git_icons.Add, results["inserted"],
            -- this will always be 1 becuse this is per 1 file
            -- git_icons.Mod, results["changed"],
            git_icons.Remove, results["deleted"]
        )
    end
end)

local position = function()
    return "[" .. builtin.line_with_width(3) .. ":" .. builtin.column_with_width(2) .. "]"
end

local diagnostic_display = diagnostic.make_buffer(function(_, _, counts)
    return string.format("%s %s %s %s %s %s %s %s",
        diag_icons.Error, counts["errors"],
        diag_icons.Warning, counts["warnings"],
        diag_icons.Information, counts["infos"],
        diag_icons.Hint, counts["hints"]
    )
end)

require("el").setup {
    generator = function(window, buffer)
        local mode = extensions.gen_mode { format_string = " %s " }

        local items = {
            { mode },
            { git_branch },
            { " " },
            { git_changes },
            { " " },
            { sections.split },
            { file_icon },
            { sections.maximum_width(builtin.file_relative, 0.60) },
            { sections.collapse_builtin { { " " }, { builtin.modified_flag } } },
            { sections.split },
            { diagnostic_display },
            { " " },
            { position },
            {
                sections.collapse_builtin {
                    "[",
                    builtin.help_list,
                    builtin.readonly_list,
                    "]",
                },
            },
            { builtin.filetype },
        }

        local add_item = function(result, item)
            if item.min_width and item.min_width then
                return
            end

            table.insert(result, item)
        end

        local result = {}
        for _, item in ipairs(items) do
            add_item(result, item)
        end

        return result
    end,
}

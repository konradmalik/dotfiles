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
local lsp = require "el.lsp"

local navic_ok, navic = pcall(require, "nvim-navic")

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local ui_icons = icons.ui

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
    if results["untracked"] then
        return " " .. git_icons.Untracked .. " "
    elseif results["ignored"] then
        return " " .. git_icons.Ignore .. " "
    elseif results["inserted"] then
        return string.format(" %s %s %s %s ",
            git_icons.Add, results["inserted"],
            -- this will always be 1 becuse this is per 1 file
            -- git_icons.Mod, results["changed"],
            git_icons.Remove, results["deleted"]
        )
    end
    return ""
end)

local progress = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local chars = ui_icons.Animations.Fill
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return chars[index]
end

local position = function()
    return string.format("[%s %s:%s]", progress(), builtin.line_with_width(3), builtin.column_with_width(3))
end

local diagnostic_display = diagnostic.make_buffer(function(_, buffer, counts)
    if next(lsp.get_lsp_servers(buffer)) == nil then
        return ""
    end

    return string.format("%s %s %s %s %s %s %s %s",
        diag_icons.Error, counts["errors"],
        diag_icons.Warning, counts["warnings"],
        diag_icons.Information, counts["infos"],
        diag_icons.Hint, counts["hints"]
    )
end)

local lsp_servers = lsp.make_buffer(function(_, _, names)
    if next(names) == nil then
        return ""
    end

    return string.format(" (%s %s) ",
        ui_icons.Gears,
        table.concat(names, "+")
    )
end)

local navic_method = function()
    if not navic_ok or not navic.is_available then
        return ""
    end
    return string.format("%s %s", ui_icons.Code, navic.get_location())
end

local hostname = function()
    local ssh_connection = vim.loop.os_getenv("SSH_CONNECTION")
    if not ssh_connection then
        return ""
    end
    return string.format("[ssh@%s]", builtin.hostname())
end

require("el").setup {
    generator = function(window, buffer)
        local mode = extensions.gen_mode { format_string = " %s " }

        local items = {
            { mode },
            { git_branch },
            { git_changes, min_width = 80 },
            -- { navic_method, min_width = 80 },
            { sections.split },
            { file_icon },
            { sections.maximum_width(builtin.file_relative, 0.60) },
            { sections.collapse_builtin { { " " }, { builtin.modified_flag } } },
            { sections.split },
            { diagnostic_display },
            { lsp_servers, min_width = 80 },
            { position },
            {
                sections.collapse_builtin {
                    "[",
                    builtin.help_list,
                    builtin.readonly_list,
                    "]",
                },
            },
            { hostname },
            { builtin.filetype },
        }

        local add_item = function(result, item)
            if item.min_width and vim.fn.winwidth(buffer.bufnr) < item.min_width then
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

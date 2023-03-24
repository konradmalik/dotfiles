local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    vim.notify("cannot load lualine")
    return
end

local larger_than = function(n)
    return vim.fn.winwidth(0) > n
end

local larger_than_80 = function()
    return larger_than(80)
end

local larger_than_120 = function()
    return larger_than(120)
end

local has_lsp = function()
    return next(vim.lsp.get_active_clients()) ~= nil
end

local navic
local navic_bar = {
    function()
        return navic.get_location()
    end,
    cond = function()
        if not has_lsp() or not larger_than_120() then
            return false
        end
        local ok
        ok, navic = pcall(require, "nvim-navic")
        if not ok then
            return false
        end
        return navic.is_available()
    end,
}

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local ui_icons = icons.ui
local line_icons = icons.lines

local mode = {
    "mode",
    fmt = string.lower,
}

local branch = {
    "branch",
    icon = git_icons.Branch,
}

local filename = {
    "filename",
    file_status = true,
    path = 1,
}

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn", "info", "hint" },
    symbols = { error = diag_icons.Error .. " ", warn = diag_icons.Warning .. " ", diag_icons.Information .. " ",
        diag_icons.Hint .. " " },
    colored = false,
    update_in_insert = false,
    always_visible = true,
    cond = function() return has_lsp() and larger_than_80() end,
}

local diff = {
    "diff",
    colored = false,
    symbols = { added = git_icons.Add .. " ", modified = git_icons.Mod .. " ", removed = git_icons.Remove .. " " }, -- changes diff symbols
    cond = larger_than_120,
}

local encoding = {
    "encoding",
    cond = larger_than_120,
}

local fileformat = {
    "fileformat",
    cond = larger_than_120,
}

local filetype = {
    "filetype",
}

local lsp_servers = {
    function()
        local names = {}
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')

        vim.lsp.for_each_buffer_client(0, function(client, _, _)
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                table.insert(names, client.name)
            end
        end)
        return string.format("[%s]", table.concat(names, ","))
    end,
    icon = ui_icons.Gears,
    cond = function() return has_lsp() and larger_than_120() end,
}

local hostname = {
    "hostname",
}

local progress = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local chars = ui_icons.Animations.Fill
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return chars[index]
end

local location = {
    "location",
}

lualine.setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = line_icons.Edge, right = line_icons.Edge },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
        always_divide_middle = false,
    },
    sections = {
        lualine_a = { mode },
        lualine_b = { branch, diff },
        lualine_c = {},
        -- lualine_x = { recording, encoding, fileformat, filetype },
        lualine_x = { encoding, fileformat, filetype },
        lualine_y = { diagnostics, lsp_servers },
        lualine_z = { progress, location, hostname },
    },
    -- does not get used due to global statusline
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { filename },
        lualine_x = { location },
        lualine_y = {},
        lualine_z = {},
    },
    winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { filename, navic_bar },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { filename },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { "fzf" },
})

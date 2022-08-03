local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    vim.notify("cannot load lualine")
    return
end

local navic_ok, navic = pcall(require, "nvim-navic")

local larger_than = function(n)
    return vim.fn.winwidth(0) > n
end

local larger_than_80 = function()
    return larger_than(80)
end

local larger_than_120 = function()
    return larger_than(120)
end

local ssh = function()
    local ssh_connection = vim.loop.os_getenv("SSH_CONNECTION")
    if not ssh_connection then
        return ""
    end
end

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
    cond = larger_than_80,
}

local navic_bar = {
    cond = function() return false end,
}
if navic_ok then
    navic_bar = {
        navic.get_location,
        cond = function() return navic.is_available and larger_than_120() end,
    }
end

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

local lsp = {
    -- Lsp server name .
    function()
        -- 0 is the current buffer
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.buf_get_clients(0)
        local msg = "No Active Lsp"
        if next(clients) == nil then
            return msg
        end
        for i, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                if i == 1 then
                    msg = client.name
                else
                    msg = string.format("%s+%s", msg, client.name)
                end
            end
        end
        return msg
    end,
    icon = ui_icons.Gears,
    cond = larger_than_120,
}

local hostname = {
    "hostname",
    cond = larger_than_80 and ssh,
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
        lualine_c = { filename, navic_bar },
        lualine_x = { encoding, fileformat, filetype },
        lualine_y = { diagnostics, lsp },
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
    tabline = {},
    extensions = { "fzf" },
})

local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    vim.notify("cannot load lualine")
    return
end

local navic_ok, navic = pcall(require, "nvim-navic")
local navic_bar       = {}
if navic_ok then
    navic_bar = { navic.get_location, cond = navic.is_available }
end

local hide_in_width = function()
    return vim.fn.winwidth(0) > 80
end

local icons = require("konrad.icons")
local diag_icons = icons.diagnostics
local git_icons = icons.git
local ui_icons = icons.ui
local line_icons = icons.lines

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn" },
    symbols = { error = diag_icons.Error .. " ", warn = diag_icons.Warning .. " " },
    colored = false,
    update_in_insert = false,
    always_visible = true,
}

local diff = {
    "diff",
    colored = false,
    symbols = { added = git_icons.Add .. " ", modified = git_icons.Mod .. " ", removed = git_icons.Remove .. " " }, -- changes diff symbols
    cond = hide_in_width
}

local mode = {
    "mode",
}

local filetype = {
    "filetype",
}

local filename = {
    "filename",
    file_status = true,
}

local branch = {
    "branch",
    icon = git_icons.Branch,
}

local location = {
    "location",
    padding = 0,
}

-- cool function for progress
local progress = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local chars = ui_icons.Animations.Fill
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return chars[index]
end

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
                    msg = string.format("%s + %s", msg, client.name)
                end
            end
        end
        return msg
    end,
    icon = ui_icons.Gears,
}

lualine.setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = line_icons.Edge, right = line_icons.Edge },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { mode },
        lualine_b = { branch, filename },
        lualine_c = { diagnostics, navic_bar },
        lualine_x = { diff, "encoding", "fileformat", filetype, lsp },
        lualine_y = { "hostname" },
        lualine_z = { progress, location },
    },
    -- does not get used due to global statusline
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { "fzf" },
})

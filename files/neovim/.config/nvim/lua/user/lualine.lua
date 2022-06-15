local lualine_ok, lualine = pcall(require, "lualine")
if not lualine_ok then
    vim.notify("cannot load lualine")
    return
end

local navic_ok, navic = pcall(require, "nvim-navic")
if not navic_ok then
    vim.notify("cannot load navic")
    return
end

lualine.setup({
    options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        icons_enabled = true,
    },
    sections = {
        lualine_a = { { "mode", upper = true } },
        lualine_b = { { "branch", icon = "" } },
        lualine_c = { { "filename", file_status = true }, { "diagnostics", sources = { "nvim_diagnostic" } }, { navic.get_location, cond = navic.is_available } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "hostname" },
        lualine_z = { "progress", "location" },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
    },
    extensions = { "fzf" },
})

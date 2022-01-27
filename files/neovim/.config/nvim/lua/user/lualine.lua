require("lualine").setup({
	options = {
		--theme = "gruvbox",
		theme = "auto",
		section_separators = "",
		component_separators = "",
		icons_enabled = true,
	},
	sections = {
		lualine_a = { { "mode", upper = true } },
		lualine_b = { { "branch", icon = "" } },
		lualine_c = { { "filename", file_status = true }, { "diagnostics", sources = { "nvim_diagnostic" } } },
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
